#!/usr/bin/env tsx
import fs from 'fs/promises';
import { constants as fsConstants } from 'fs';
import path from 'path';
import { pathToFileURL } from 'url';
import { glob } from 'glob';
import { parseStringPromise } from 'xml2js';
import { writeErrorSummary } from './error-handler.ts';
import { buildSummary, summaryToMarkdown, requirementsSummaryToMarkdown, requirementTestsToMarkdown, groupToMarkdown, TestCase, RequirementGroup } from './summary/index.ts';
import { generateActionDocs } from './summary/generate-action-docs.ts';


function normalizeTestId(id: string): string {
  return id.toLowerCase().replace(/::/g, '-').replace(/\s+/g, '-');
}

function redact(text: string): string {
  return text.replace(/[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+/g, '<redacted>');
}

export async function loadRequirements(mappingFile: string) {
  try {
    const raw = await fs.readFile(mappingFile, 'utf8');
    const parsed = JSON.parse(raw);
    const defaults: Record<string, any> = parsed.runners || parsed.defaults || {};
    const map: Record<string, { requirements: string[]; owner?: string }> = {};
    const meta: Record<string, { description?: string; owner?: string; runner_label?: string; runner_type?: string; skip_dry_run?: boolean }> = {};
    if (Array.isArray(parsed.requirements)) {
      for (const r of parsed.requirements) {
        const def = (r.runner && defaults[r.runner]) || {};
        const owner = r.owner ?? def.owner;
        const runner_label = r.runner_label ?? def.runner_label;
        const runner_type = r.runner_type ?? def.runner_type;
        const skip_dry_run = r.skip_dry_run ?? def.skip_dry_run;
        meta[r.id] = { description: r.description, owner, runner_label, runner_type, skip_dry_run };
        if (Array.isArray(r.tests)) {
          for (const t of r.tests) {
            const key = t.toLowerCase();
            if (!map[key]) map[key] = { requirements: [], owner };
            map[key].requirements.push(r.id);
          }
        }
      }
    }
    return { map, meta };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.warn(`Failed to load requirements mapping from ${mappingFile}: ${msg}`);
    await writeErrorSummary(err);
    return { map: {}, meta: {} };
  }
}

export async function collectTestCases(files: string[], evidenceDir: string, os?: string): Promise<TestCase[]> {
  const evidenceFiles = await fs.readdir(evidenceDir).catch(() => []);
  const tests: TestCase[] = [];
  const osType = (os ?? process.env.RUNNER_OS ?? 'unknown').toLowerCase();
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
          const className = tc.classname?.[0];
          const id = normalizeTestId(name);
          let status: 'Passed' | 'Failed' | 'Skipped' = 'Passed';
          if (tc.failure || tc.error) status = 'Failed';
          else if (tc.skipped) status = 'Skipped';
          const duration = parseFloat(tc.time?.[0] ?? '0');
          const test: TestCase = { id, name, className, status, duration, requirements: [], os: osType };
            const props = tc.properties?.[0]?.property;
            if (Array.isArray(props)) {
              const findProp = (n: string) =>
                props.find((p: any) => p.name?.[0]?.toLowerCase() === n);
              const ownerProp = findProp('owner') ?? findProp('machine-name');
              const ownerVal = ownerProp?.value?.[0] ?? ownerProp?._;
              if (ownerVal) test.owner = ownerVal;
              const evidenceProp = props.find((p: any) =>
                ['evidence', 'attachment', 'ci_link'].includes((p.name?.[0] ?? '').toLowerCase())
              );
              const evidenceVal = evidenceProp?.value?.[0] ?? evidenceProp?._;
              if (evidenceVal) test.evidence = evidenceVal;
              for (const p of props) {
                if (p.name?.[0]?.toLowerCase() === 'requirement') {
                  const val = p.value?.[0] ?? p._;
                  if (typeof val === 'string') test.requirements.push(val.toUpperCase());
                }
              }
            }
          if (!test.evidence) {
            const evidence = evidenceFiles.find((f) => f.startsWith(id) || f.startsWith(id + '.'));
            if (evidence) test.evidence = path.join('evidence', evidence);
          }
          if (!test.owner) {
            const ownerMatch = name.match(/\[Owner:([^\]]+)\]/i);
            if (ownerMatch) test.owner = ownerMatch[1];
          }
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

export function mapToRequirements(
  tests: TestCase[],
  mapping: Record<string, { requirements: string[]; owner?: string }>,
  meta: Record<string, { description?: string; owner?: string; runner_label?: string; runner_type?: string; skip_dry_run?: boolean }>
): RequirementGroup[] {
  const groups: Map<string, RequirementGroup> = new Map();
  for (const test of tests) {
    const stripAnnotations = (s: string) => s.replace(/\[[^\]]+\]/g, '').trim();
    const nameKey = stripAnnotations(test.name).toLowerCase();
    const classKey = test.className ? stripAnnotations(test.className).toLowerCase() : undefined;
    const mapped = mapping[nameKey] || (classKey ? mapping[classKey] : undefined);
    const reqs = mapped ? mapped.requirements : test.requirements;
    if (mapped && mapped.owner) test.owner = mapped.owner;
    if (!test.owner) {
      for (const r of reqs) {
        if (meta[r]?.owner) {
          test.owner = meta[r].owner;
          break;
        }
      }
    }
    const targetReqs = reqs.length ? reqs : ['Unmapped'];
    for (const reqId of targetReqs) {
      if (!groups.has(reqId)) {
        groups.set(reqId, {
          id: reqId,
          description: meta[reqId]?.description,
          owner: meta[reqId]?.owner,
          runner_label: meta[reqId]?.runner_label,
          runner_type: meta[reqId]?.runner_type,
          skip_dry_run: meta[reqId]?.skip_dry_run,
          tests: [],
        });
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


async function main() {
  const mappingFile = process.env.REQ_MAPPING_FILE || 'requirements.json';
  const dispatcherRegistryFile = process.env.DISPATCHER_REGISTRY || 'dispatchers.json';
  const evidenceDir = process.env.EVIDENCE_DIR || 'test-screenshots';
  const osType = (process.env.RUNNER_OS ?? 'unknown').toLowerCase();

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
    const single = process.env.TEST_RESULTS_GLOB || '**/*junit*.xml';
    junitFiles = await glob(single, { nodir: true });
  }
  let tests: TestCase[] = [];
  if (junitFiles.length === 0) {
    console.warn('No JUnit files found; writing empty summary.');
  } else {
    tests = await collectTestCases(junitFiles, evidenceDir, osType);
  }
  const { map, meta } = await loadRequirements(mappingFile);
  const groups = mapToRequirements(tests, map, meta);
  const totals = buildSummary(groups);

  const outDir = path.join('artifacts', osType);
  await fs.mkdir(outDir, { recursive: true });

  const matrixMd = groupToMarkdown(groups);
  const summaryMd = summaryToMarkdown(totals);
  const requirementsMd = requirementsSummaryToMarkdown(groups);
  const requirementsTestsMd = requirementTestsToMarkdown(groups);

  const wrapperFiles = await glob('*/action.yml', { nodir: true });
  const wrapperDirs = wrapperFiles.map(f => path.dirname(f)).sort();
  console.log('Discovered wrapper directories:', wrapperDirs.join(', '));
  const { docs, markdown } = await generateActionDocs(dispatcherRegistryFile, wrapperDirs);

  await fs.writeFile(path.join(outDir, 'traceability.json'), JSON.stringify({ requirements: groups, totals }, null, 2));
  await fs.writeFile(path.join(outDir, 'traceability.md'), redact(`### Test Traceability Matrix\n\n${matrixMd}`));
  const combinedSummary = `${summaryMd}\n\n${requirementsMd}\n\n_For detailed per-test information, see [traceability.md](traceability.md)._`;
  await fs.writeFile(path.join(outDir, 'summary.md'), redact(combinedSummary));
  const reqSummary = `${requirementsMd}\n\n${requirementsTestsMd}`;
  await fs.writeFile(path.join(outDir, 'requirements-summary.md'), redact(reqSummary));
  await fs.writeFile(path.join(outDir, 'action-docs.json'), JSON.stringify(docs, null, 2));
  await fs.writeFile(path.join(outDir, 'action-docs.md'), redact(markdown));

  const partitions: Record<string, RequirementGroup[]> = {};
  for (const g of groups) {
    const type = g.runner_type ?? 'standard';
    if (!partitions[type]) partitions[type] = [];
    partitions[type].push(g);
  }

  for (const [type, list] of Object.entries(partitions)) {
    const partTotals = buildSummary(list);
    const partSummary = summaryToMarkdown(partTotals);
    await fs.writeFile(
      path.join(outDir, `summary-${type}.md`),
      redact(
        `${partSummary}\n\n_For detailed per-test information, see [traceability-${type}.md](traceability-${type}.md)._`,
      ),
    );
    await fs.writeFile(
      path.join(outDir, `traceability-${type}.md`),
      redact(`### Test Traceability Matrix\n\n${groupToMarkdown(list)}`),
    );
  }

  try {
    await fs.access(evidenceDir, fsConstants.R_OK);
    await fs.cp(evidenceDir, path.join(outDir, 'evidence'), { recursive: true });
  } catch {
    // ignore missing evidence
  }
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  main().catch(async (err: unknown) => {
    await writeErrorSummary(err);
    process.exit(1);
  });
}

