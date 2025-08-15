#!/usr/bin/env ts-node
import { promises as fs } from 'fs';
import path from 'path';
import { glob } from 'glob';
import { parseStringPromise } from 'xml2js';
import { execFile } from 'child_process';
import { promisify } from 'util';
import JSZip from 'jszip';

const execFileAsync = promisify(execFile);

interface Requirement {
  id: string;
  description: string;
  tests: string[];
}

/**
 * Load requirement mappings from a JSON file. Returns empty array when file
 * cannot be parsed or does not exist.
 */
export async function loadRequirementMapping(mappingPath: string): Promise<Requirement[]> {
  try {
    const contents = await fs.readFile(mappingPath, 'utf8');
    const parsed = JSON.parse(contents);
    return Array.isArray(parsed.requirements) ? (parsed.requirements as Requirement[]) : [];
  } catch (err: any) {
    console.warn(`Unable to read requirement mapping file at ${mappingPath}: ${err.message}`);
    return [];
  }
}

/**
 * Find the requirement identifier for a given test name. Returns undefined if
 * the test name is not associated with any requirement.
 */
export function findRequirementId(testName: string, mapping: Requirement[]): string | undefined {
  for (const req of mapping) {
    if (req.tests.includes(testName)) {
      return req.id;
    }
  }
  return undefined;
}

interface SuiteResult {
  name: string;
  tests: number;
  failures: number;
  passed: number;
}

export async function parseJUnitFile(file: string): Promise<SuiteResult[]> {
  const xml = await fs.readFile(file, 'utf8');
  const data = await parseStringPromise(xml);
  const suites: any[] = [];
  if (data.testsuite) {
    suites.push(data.testsuite);
  } else if (data.testsuites && Array.isArray(data.testsuites.testsuite)) {
    suites.push(...data.testsuites.testsuite);
  } else if (data.testsuites && data.testsuites.testsuite) {
    suites.push(data.testsuites.testsuite);
  } else if (data.testsuites && data.testsuites.testcase) {
    const cases = Array.isArray(data.testsuites.testcase)
      ? data.testsuites.testcase
      : [data.testsuites.testcase];
    const failures = cases.filter((c: any) => c.failure || c.error).length;
    suites.push({
      $: {
        name: path.basename(file),
        tests: String(cases.length),
        failures: String(failures),
      },
    });
  }
  return suites.map((suite) => {
    const attrs = suite.$ || {};
    const tests = parseInt(attrs.tests ?? '0', 10);
    const failures = parseInt(attrs.failures ?? '0', 10) + parseInt(attrs.errors ?? '0', 10);
    const skipped = parseInt(attrs.skipped ?? attrs.disabled ?? '0', 10);
    const passed = tests - failures - skipped;
    return { name: attrs.name ?? path.basename(file), tests, failures, passed } as SuiteResult;
  });
}

async function appendSummary(results: SuiteResult[]): Promise<void> {
  const summaryPath = process.env.GITHUB_STEP_SUMMARY;
  if (!summaryPath) return;
  let md = '| Test Suite | Passed | Failed |\n| --- | --- | --- |\n';
  for (const r of results) {
    md += `| ${r.name} | ${r.passed} | ${r.failures} |\n`;
  }
  await fs.appendFile(summaryPath, md);
}

export async function writeTraceability(results: SuiteResult[], mapping: Requirement[]): Promise<void> {
  const trace: Record<string, unknown> = {};
  for (const r of results) {
    const req = findRequirementId(r.name, mapping);
    if (req) {
      trace[req] = { test: r.name, passed: r.failures === 0, failed: r.failures, passedTests: r.passed, total: r.tests };
    }
  }
  await fs.mkdir('artifacts', { recursive: true });
  await fs.writeFile(path.join('artifacts', 'traceability.json'), JSON.stringify(trace, null, 2));
}

interface ActionParameter {
  name: string;
  type: string;
  required: boolean;
  description: string;
}

interface ActionInfo {
  name: string;
  synopsis: string;
  description: string;
  parameters: ActionParameter[];
}

async function getActionInfo(scriptPath: string): Promise<ActionInfo> {
  const psCommand = `Get-Help -Full -Path \"${scriptPath}\" | ConvertTo-Json -Depth 4`;
  const { stdout } = await execFileAsync('pwsh', ['-NoLogo', '-NoProfile', '-Command', psCommand], { maxBuffer: 10 * 1024 * 1024 });
  const help = JSON.parse(stdout);
  const synopsis = help.Synopsis ?? '';
  const description = Array.isArray(help.Description?.Text) ? help.Description.Text.join(' ') : (help.Description?.Text ?? '');
  const paramsRaw = help.Parameters?.Parameter ?? [];
  const paramsArr = Array.isArray(paramsRaw) ? paramsRaw : [paramsRaw];
  const parameters: ActionParameter[] = paramsArr
    .filter((p: any) => p)
    .map((p: any) => ({
      name: p.Name ?? '',
      type: p.ParameterType?.Name ?? '',
      required: String(p.Required).toLowerCase() === 'true',
      description: Array.isArray(p.Description?.Text) ? p.Description.Text.join(' ') : (p.Description?.Text ?? ''),
    }));
  return { name: path.basename(path.dirname(scriptPath)), synopsis, description, parameters };
}

export function renderActionDoc(template: string, info: ActionInfo): string {
  const required = info.parameters.filter((p) => p.required);
  const optional = info.parameters.filter((p) => !p.required);
  const reqLines = required.length ? required.map((p) => `- **${p.name}** (\`${p.type}\`): ${p.description}`).join('\n') : 'None.';
  const optLines = optional.length ? optional.map((p) => `- **${p.name}** (\`${p.type}\`): ${p.description}`).join('\n') : 'None.';
  const exampleArgs: Record<string, string> = {};
  for (const p of info.parameters) {
    exampleArgs[p.name] = 'value';
  }
  const argsJson = JSON.stringify(exampleArgs);
  const cliExample = ['```powershell', `pwsh -File actions/Invoke-OSAction.ps1 -ActionName ${info.name} -ArgsJson '${argsJson}'`, '```'].join('\n');
  const yamlExample = [
    '```yaml',
    `- name: ${info.synopsis || info.name}`,
    '  uses: LabVIEW-Community-CI-CD/open-source-actions@v1',
    '  with:',
    `    action_name: ${info.name}`,
    '    args_json: >-',
    `      ${argsJson}`,
    '```',
  ].join('\n');

  let md = template.replace(/<action-name>/g, info.name);
  md = md.replace('Briefly describe the action\'s goal.', info.synopsis || info.description || '');
  md = md.replace('### Required\n\n- **Param1** (`type`): Description.\n\n', `### Required\n\n${reqLines}\n\n`);
  md = md.replace('### Optional\n\n- **Param2** (`type`): Description.\n\n', `### Optional\n\n${optLines}\n\n`);
  md = md.replace(/```powershell[\s\S]*?```/, cliExample);
  md = md.replace(/```yaml[\s\S]*?```/, yamlExample);
  return md;
}

async function zipDirectory(sourceDir: string, outPath: string): Promise<void> {
  const zip = new JSZip();
  const root = zip.folder(path.basename(sourceDir));
  if (!root) throw new Error('Unable to create zip folder');
  async function addDir(dir: string, folder: JSZip): Promise<void> {
    const entries = await fs.readdir(dir, { withFileTypes: true });
    for (const entry of entries) {
      const full = path.join(dir, entry.name);
      if (entry.isDirectory()) {
        const sub = folder.folder(entry.name);
        if (sub) await addDir(full, sub);
      } else if (entry.isFile()) {
        const data = await fs.readFile(full);
        folder.file(entry.name, data);
      }
    }
  }
  await addDir(sourceDir, root);
  const content = await zip.generateAsync({ type: 'nodebuffer' });
  await fs.writeFile(outPath, content);
}

export async function generateActionDocs(): Promise<void> {
  const scripts = await glob('scripts/*/*.ps1');
  if (scripts.length === 0) return;
  const template = await fs.readFile(path.join('doc-templates', 'action-doc-template.md'), 'utf8');
  const outDir = path.join('artifacts', 'action-docs');
  await fs.mkdir(outDir, { recursive: true });
  for (const script of scripts) {
    try {
      const info = await getActionInfo(script);
      const md = renderActionDoc(template, info);
      await fs.writeFile(path.join(outDir, `${info.name}.md`), md);
    } catch (err: any) {
      console.warn(`Failed to document ${script}: ${err.message}`);
    }
  }
  try {
    await zipDirectory(outDir, path.join('artifacts', 'action-docs.zip'));
  } catch (err: any) {
    throw new Error(`Failed to zip action docs: ${err.message}`);
  }
}

export async function main() {
  const patternsEnv = process.env.TEST_RESULTS_GLOBS;
  if (!patternsEnv) {
    console.warn('TEST_RESULTS_GLOBS not set');
    return;
  }

  const patterns = patternsEnv.split(/\r?\n|[ ,]+/).filter(Boolean);
  const files = new Set<string>();
  for (const pattern of patterns) {
    const matches = await glob(pattern);
    for (const m of matches) {
      files.add(m);
    }
  }

  const results: SuiteResult[] = [];
  for (const file of files) {
    const suites = await parseJUnitFile(file);
    results.push(...suites);
  }

  await appendSummary(results);

  const mappingFile = process.env.REQ_MAPPING_FILE ?? 'requirements.json';
  const mapping = await loadRequirementMapping(path.resolve(mappingFile));
  let artifactError = false;
  try {
    await writeTraceability(results, mapping);
    await generateActionDocs();
    await fs.access(path.join('artifacts', 'traceability.json'));
    await fs.access(path.join('artifacts', 'action-docs.zip'));
  } catch (err: any) {
    console.error(`Artifact generation failed: ${err.message}`);
    artifactError = true;
  }

  if (results.some((r) => r.failures > 0) || artifactError) {
    process.exitCode = 1;
  }
}

// Only run main when executed directly (not when imported for tests)
if (process.argv[1] && process.argv[1].endsWith('generate-ci-summary.ts')) {
  main();
}
