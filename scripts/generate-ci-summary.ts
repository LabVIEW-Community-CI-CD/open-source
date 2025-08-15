#!/usr/bin/env node
import fs from 'fs/promises';
import path from 'path';
import { fileURLToPath, pathToFileURL } from 'url';
import { glob } from 'glob';
import { parseStringPromise } from 'xml2js';
import yaml from 'js-yaml';

interface TestCase {
  id: string;
  name: string;
  status: 'Passed' | 'Failed' | 'Skipped';
  duration: number;
  owner?: string;
  evidence?: string;
  requirements: string[];
}

interface RequirementGroup {
  id: string;
  description?: string;
  owner?: string;
  tests: TestCase[];
}

function normalizeTestId(id: string): string {
  return id.toLowerCase().replace(/::/g, '-').replace(/\s+/g, '-');
}

function redact(text: string): string {
  return text.replace(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+/g, '<redacted>');
}

async function loadRequirements(mappingFile: string) {
  try {
    const raw = await fs.readFile(mappingFile, 'utf8');
    const parsed = JSON.parse(raw);
    const map: Record<string, { requirements: string[]; owner?: string }> = {};
    const meta: Record<string, { description?: string; owner?: string }> = {};
    if (Array.isArray(parsed.requirements)) {
      for (const r of parsed.requirements) {
        meta[r.id] = { description: r.description, owner: r.owner };
        if (Array.isArray(r.tests)) {
          for (const t of r.tests) {
            const key = t.toLowerCase();
            if (!map[key]) map[key] = { requirements: [], owner: r.owner };
            map[key].requirements.push(r.id);
          }
        }
      }
    }
    return { map, meta };
  } catch {
    return { map: {}, meta: {} };
  }
}

async function collectTestCases(files: string[], evidenceDir: string): Promise<TestCase[]> {
  const evidenceFiles = await fs.readdir(evidenceDir).catch(() => []);
  const tests: TestCase[] = [];
  const statusMap: Record<string, 'Passed' | 'Failed' | 'Skipped'> = {
    passed: 'Passed',
    failed: 'Failed',
    skipped: 'Skipped',
  };
  for (const file of files) {
    const xml = await fs.readFile(file, 'utf8');
    const data = await parseStringPromise(xml, { explicitArray: true, mergeAttrs: true });
    const suites: any[] = [];
    if (data.testsuite) suites.push(data.testsuite);
    if (data.testsuites) {
      if (Array.isArray(data.testsuites.testsuite)) suites.push(...data.testsuites.testsuite);
      else if (data.testsuites.testsuite) suites.push(data.testsuites.testsuite);
    }
    const collect = (obj: any) => {
      if (!obj) return;
      if (Array.isArray(obj.testcase)) {
        for (const tc of obj.testcase) {
          const name = tc.name?.[0] ?? 'unknown';
          const id = normalizeTestId(name);
          let status: 'Passed' | 'Failed' | 'Skipped' = 'Passed';
          if (tc.failure || tc.error) status = 'Failed';
          else if (tc.skipped) status = 'Skipped';
          const duration = parseFloat(tc.time?.[0] ?? '0');
          const test: TestCase = { id, name, status, duration, requirements: [] };
          const evidence = evidenceFiles.find((f) => f.startsWith(id) || f.startsWith(id + '.'));
          if (evidence) test.evidence = path.join('evidence', evidence);
          const ownerMatch = name.match(/\[Owner:([^\]]+)\]/i);
          if (ownerMatch) test.owner = ownerMatch[1];
          const reqMatches = [...name.matchAll(/\[(REQ-\d+)\]/gi)].map((m) => m[1].toUpperCase());
          if (reqMatches.length) test.requirements.push(...reqMatches);
          tests.push(test);
        }
      }
      if (Array.isArray(obj.testsuite)) {
        for (const s of obj.testsuite) collect(s);
      }
    };
    for (const s of suites) collect(s);
  }
  return tests;
}

function mapToRequirements(tests: TestCase[], mapping: Record<string, { requirements: string[]; owner?: string }>, meta: Record<string, { description?: string; owner?: string }>): RequirementGroup[] {
  const groups: Map<string, RequirementGroup> = new Map();
  for (const test of tests) {
    const mapped = mapping[test.name.toLowerCase()];
    const reqs = mapped ? mapped.requirements : test.requirements;
    if (mapped && mapped.owner) test.owner = mapped.owner;
    const targetReqs = reqs.length ? reqs : ['Unmapped'];
    for (const reqId of targetReqs) {
      if (!groups.has(reqId)) {
        groups.set(reqId, { id: reqId, description: meta[reqId]?.description, owner: meta[reqId]?.owner, tests: [] });
      }
      groups.get(reqId)!.tests.push(test);
    }
  }
  const statusRank: Record<string, number> = { Failed: 0, Passed: 1, Skipped: 2 };
  const sorted = Array.from(groups.values()).sort((a, b) => a.id.localeCompare(b.id, undefined, { numeric: true }));
  for (const g of sorted) {
    g.tests.sort((a, b) => {
      const diff = statusRank[a.status] - statusRank[b.status];
      if (diff !== 0) return diff;
      return a.name.localeCompare(b.name);
    });
  }
  return sorted;
}

function buildSummary(groups: RequirementGroup[]) {
  let passed = 0, failed = 0, skipped = 0, duration = 0;
  for (const g of groups) {
    for (const t of g.tests) {
      duration += t.duration;
      if (t.status === 'Passed') passed++; else if (t.status === 'Failed') failed++; else skipped++;
    }
  }
  const rate = passed + failed === 0 ? 0 : (passed / (passed + failed)) * 100;
  return { passed, failed, skipped, duration, rate };
}

function groupToMarkdown(groups: RequirementGroup[], limit?: number) {
  const lines: string[] = [];
  let count = 0;
  for (const g of groups) {
    const total = g.tests.length;
    const passedCount = g.tests.filter((t) => t.status === 'Passed').length;
    const pct = total === 0 ? 0 : Math.round((passedCount / total) * 100);
    const header = `${g.id} (${pct}% passed)`;
    const table = ['| Requirement | Test ID | Status | Duration (s) | Owner | Evidence |', '| --- | --- | --- | --- | --- | --- |'];
    for (const t of g.tests) {
      if (limit && count >= limit) break;
      const evidence = t.evidence ? `[link](${t.evidence})` : '';
      table.push(`| ${g.id} | ${t.name} | ${t.status} | ${t.duration.toFixed(3)} | ${t.owner ?? ''} | ${evidence} |`);
      count++;
    }
    const content = table.join('\n');
    if (g.tests.length > 5) {
      lines.push(`<details><summary>${header}</summary>\n\n${content}\n\n</details>`);
    } else {
      lines.push(`#### ${header}\n\n${content}`);
    }
    if (limit && count >= limit) break;
  }
  if (limit && count >= limit) lines.push('\n_Truncated. See traceability.md for full details._');
  return lines.join('\n\n');
}

async function generateActionDocs(dispatcherRegistryFile: string, wrapperDirs: string[]) {
  const actionYaml = yaml.load(await fs.readFile('action.yml', 'utf8')) as any;
  const actionParams = Object.entries(actionYaml.inputs || {}).map(([name, info]: any) => ({
    name,
    description: info.description || '',
    required: info.required === true,
    default: info.default ?? '',
    type: info.type || 'string',
  }));

  let registry: any = null;
  try {
    const ext = path.extname(dispatcherRegistryFile);
    if (ext === '.json') {
      registry = JSON.parse(await fs.readFile(dispatcherRegistryFile, 'utf8'));
    } else {
      const mod = await import(pathToFileURL(path.resolve(dispatcherRegistryFile)).href);
      registry = mod.default ?? mod;
    }
  } catch {
    registry = null;
  }

  const wrappers: Record<string, any[]> = {};
  for (const dir of wrapperDirs) {
    const p = path.join(dir, 'action.yml');
    try {
      const y = yaml.load(await fs.readFile(p, 'utf8')) as any;
      const params = Object.entries(y.inputs || {}).map(([n, inf]: any) => ({
        name: n,
        description: inf.description || '',
        required: inf.required === true,
        default: inf.default ?? '',
        type: inf.type || 'string',
      }));
      wrappers[dir] = params;
    } catch {
      continue;
    }
  }

  const docs = { action: actionParams, dispatcher: registry, wrappers };
  const lines: string[] = ['### Parameters', '| Name | Type | Required | Default | Description |', '| --- | --- | --- | --- | --- |'];
  for (const p of actionParams) {
    lines.push(`| ${p.name} | ${p.type} | ${p.required} | ${p.default} | ${p.description} |`);
  }
  if (registry) {
    lines.push('\n### Dispatcher Functions');
    const fnNames = Object.keys(registry).sort();
    for (const fn of fnNames) {
      const info = registry[fn];
      lines.push(`\n#### ${fn}`);
      if (info.description) lines.push(info.description);
      const tbl = ['| Parameter | Type | Required | Default | Description |', '| --- | --- | --- | --- | --- |'];
      const paramNames = Object.keys(info.parameters || {}).sort();
      for (const pn of paramNames) {
        const p = info.parameters[pn];
        tbl.push(`| ${pn} | ${p.type} | ${p.required} | ${p.default ?? ''} | ${p.description ?? ''} |`);
      }
      lines.push(tbl.join('\n'));
      lines.push('\n```yaml');
      lines.push('- uses: ./');
      lines.push('  with:');
      lines.push(`    action_name: ${fn}`);
      lines.push('    args_json: "{}"');
      lines.push('```');
    }
  }
  if (Object.keys(wrappers).length) {
    lines.push('\n### Wrapper Actions');
    for (const [dir, params] of Object.entries(wrappers)) {
      lines.push(`\n#### ${dir}`);
      const tbl = ['| Name | Type | Required | Default | Description |', '| --- | --- | --- | --- | --- |'];
      for (const p of params) {
        tbl.push(`| ${p.name} | ${p.type} | ${p.required} | ${p.default} | ${p.description} |`);
      }
      lines.push(tbl.join('\n'));
    }
  }
  return { docs, markdown: lines.join('\n') };
}

async function main() {
  const mappingFile = process.env.REQ_MAPPING_FILE || 'requirements.json';
  const dispatcherRegistryFile = process.env.DISPATCHER_REGISTRY || 'dispatchers.json';
  const evidenceDir = process.env.EVIDENCE_DIR || 'test-screenshots';

  let junitFiles: string[] = [];
  const plural = process.env.TEST_RESULTS_GLOBS;
  if (plural) {
    const patterns = plural.split(/\s+/).filter(Boolean);
    const found = new Set<string>();
    for (const p of patterns) {
      const matches = await glob(p, { nodir: true });
      for (const f of matches) found.add(f);
    }
    junitFiles = Array.from(found);
  } else {
    const single = process.env.TEST_RESULTS_GLOB || '**/junit*.xml';
    junitFiles = await glob(single, { nodir: true });
  }
  if (junitFiles.length === 0) throw new Error('No JUnit files found');

  const tests = await collectTestCases(junitFiles, evidenceDir);
  const { map, meta } = await loadRequirements(mappingFile);
  const groups = mapToRequirements(tests, map, meta);
  const totals = buildSummary(groups);

  await fs.mkdir('artifacts', { recursive: true });

  const summaryLines = [`### Summary`, `- Passed: ${totals.passed}`, `- Failed: ${totals.failed}`, `- Skipped: ${totals.skipped}`, `- Pass rate: ${totals.rate.toFixed(2)}%`, `- Duration: ${totals.duration.toFixed(3)} s`, `- Commit: ${(process.env.GITHUB_SHA || '').slice(0,7)}`, `- Run ID: ${process.env.GITHUB_RUN_ID || ''}`];

  const matrixMd = groupToMarkdown(groups, tests.length > 100 ? 100 : undefined);
  const summary = `${summaryLines.join('\n')}` + `\n\n### Test Traceability Matrix\n\n${matrixMd}`;

  const wrapperFiles = await glob('*/action.yml', { nodir: true });
  const wrapperDirs = wrapperFiles.map(f => path.dirname(f)).sort();
  console.log('Discovered wrapper directories:', wrapperDirs.join(', '));
  const { docs, markdown } = await generateActionDocs(dispatcherRegistryFile, wrapperDirs);

  const actionDocMd = `### Action Documentation\n\n${markdown}`;

  const finalSummary = redact(`${summary}\n\n${actionDocMd}`);
  if (process.env.GITHUB_STEP_SUMMARY) {
    await fs.appendFile(process.env.GITHUB_STEP_SUMMARY, finalSummary + '\n');
  }

  await fs.writeFile(path.join('artifacts','traceability.json'), JSON.stringify({ requirements: groups, totals }, null, 2));
  await fs.writeFile(path.join('artifacts','traceability.md'), redact(`### Test Traceability Matrix\n\n${groupToMarkdown(groups)}`));
  await fs.writeFile(path.join('artifacts','action-docs.json'), JSON.stringify(docs, null, 2));
  await fs.writeFile(path.join('artifacts','action-docs.md'), redact(markdown));

  try {
    await fs.access(evidenceDir);
    await fs.cp(evidenceDir, path.join('artifacts','evidence'), { recursive: true });
  } catch {
    // ignore missing evidence
  }
}

main().catch(async (err) => {
  const msg = `### Error\n\n${err.message}`;
  if (process.env.GITHUB_STEP_SUMMARY) {
    await fs.appendFile(process.env.GITHUB_STEP_SUMMARY, msg + '\n');
  }
  console.error(err);
  process.exit(1);
});

