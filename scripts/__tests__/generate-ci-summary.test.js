import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { collectTestCases, loadRequirements, mapToRequirements, groupToMarkdown, buildSummary } from '../generate-ci-summary.ts';
import { writeErrorSummary } from '../error-handler.ts';

const fileUrl = new URL('../generate-ci-summary.ts', import.meta.url);

test('generate-ci-summary features', async () => {
  const content = await fs.readFile(fileUrl, 'utf8');
  assert.match(content, /TEST_RESULTS_GLOBS/);
  assert.match(content, /<redacted>/);
  assert.match(content, /<details><summary>/);
  assert.match(content, /\*\*\/\*junit\*\.xml/);
});

test('writeErrorSummary skips summary file for non-Error throws', async () => {
  const tmp = new URL('./tmp-summary.md', import.meta.url);
  await fs.rm(tmp, { force: true });
  process.env.GITHUB_STEP_SUMMARY = fileURLToPath(tmp);
  const err = Object.create(null);
  err.message = 'boom';
  await writeErrorSummary(err);
  const exists = await fs.stat(tmp).then(() => true, () => false);
  assert.strictEqual(exists, false);
  delete process.env.GITHUB_STEP_SUMMARY;
});

test('associates classname with requirement', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'junit-'));
  const xml = `<testsuite><testcase classname="Dispatcher.Tests" name="sample" time="0.1"/></testsuite>`;
  const xmlPath = path.join(dir, 'junit.xml');
  await fs.writeFile(xmlPath, xml);
  const tests = await collectTestCases([xmlPath], dir, 'linux');
  const reqPath = fileURLToPath(new URL('../../requirements.json', import.meta.url));
  const { map, meta } = await loadRequirements(reqPath);
  const groups = mapToRequirements(tests, map, meta);
  const req = groups.find((g) => g.id === 'REQ-001');
  assert(req && req.tests.some((t) => t.className === 'Dispatcher.Tests'));
  await fs.rm(dir, { recursive: true, force: true });
});

test('collectTestCases uses machine-name property for owner', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'owner-'));
  const xmlProp = `<testsuite><testcase name="foo" time="0"><properties><property name="machine-name" value="ci-bot"/></properties></testcase></testsuite>`;
  const propPath = path.join(dir, 'junit1.xml');
  await fs.writeFile(propPath, xmlProp);
  const testsProp = await collectTestCases([propPath], dir, 'linux');
  assert.strictEqual(testsProp[0].owner, 'ci-bot');

  const xmlFallback = `<testsuite><testcase name="[Owner:alice] bar" time="0"/></testsuite>`;
  const fallbackPath = path.join(dir, 'junit2.xml');
  await fs.writeFile(fallbackPath, xmlFallback);
  const testsFallback = await collectTestCases([fallbackPath], dir, 'linux');
  assert.strictEqual(testsFallback[0].owner, 'alice');

  await fs.rm(dir, { recursive: true, force: true });
});

test('groupToMarkdown assigns numeric identifiers', () => {
  const groups = [{
    id: 'REQ-XYZ',
    tests: [
      { id: 'a', name: 'alpha', status: 'Passed', duration: 0, requirements: [] },
      { id: 'b', name: 'beta', status: 'Failed', duration: 0, requirements: [] },
    ],
  }];
  const md = groupToMarkdown(groups);
  assert.match(md, /\| ID \| Requirement \| Test ID \| Status \|/);
  assert.match(md, /\| 0 \| REQ-XYZ \| alpha \| Passed \|/);
  assert.match(md, /\| 1 \| REQ-XYZ \| beta \| Failed \|/);
});

test('buildSummary splits totals by OS', () => {
  const groups = [{
    id: 'REQ-1',
    tests: [
      { id: 'a', name: 'alpha', status: 'Passed', duration: 1, requirements: [], os: 'windows' },
      { id: 'b', name: 'beta', status: 'Failed', duration: 1, requirements: [], os: 'linux' },
      { id: 'c', name: 'gamma', status: 'Skipped', duration: 1, requirements: [], os: 'linux' },
    ],
  }];
  const summary = buildSummary(groups);
  assert.strictEqual(summary.overall.passed, 1);
  assert.strictEqual(summary.byOs.windows.passed, 1);
  assert.strictEqual(summary.byOs.linux.failed, 1);
  assert.strictEqual(summary.byOs.linux.skipped, 1);
});

const execFileP = promisify(execFile);

test('writes outputs to OS-specific directory', async () => {
  const tmp = await fs.mkdtemp(path.join(os.tmpdir(), 'summary-'));
  const junitPath = path.join(tmp, 'junit.xml');
  await fs.writeFile(junitPath, '<testsuite><testcase name="foo" time="0"/></testsuite>');

  await fs.rm('artifacts', { recursive: true, force: true });

  const env = {
    ...process.env,
    TEST_RESULTS_GLOB: junitPath,
    EVIDENCE_DIR: tmp,
    RUNNER_OS: 'Windows',
  };

  await execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env });

  const outDir = path.join('artifacts', 'windows');
  const exists = await fs.stat(path.join(outDir, 'traceability.json')).then(() => true, () => false);
  assert.strictEqual(exists, true);
  const summary = await fs.readFile(path.join(outDir, 'summary.md'), 'utf8');
  assert.match(summary, /\| windows \| 1 \| 0 \| 0 \|/);

  await fs.rm(tmp, { recursive: true, force: true });
  await fs.rm('artifacts', { recursive: true, force: true });
});

test('partitions requirement groups by runner_type', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'partition-'));
  const junitPath = path.join(dir, 'junit.xml');
  const xml = '<testsuite><testcase name="alpha" time="0"/><testcase name="beta" time="0"/></testsuite>';
  await fs.writeFile(junitPath, xml);
  const req = {
    runners: { integ: { runner_type: 'integration' } },
    requirements: [
      { id: 'REQ-1', tests: ['alpha'] },
      { id: 'REQ-2', runner: 'integ', tests: ['beta'] },
    ],
  };
  const reqPath = path.join(dir, 'req.json');
  await fs.writeFile(reqPath, JSON.stringify(req));

  await fs.rm('artifacts', { recursive: true, force: true });

  const env = {
    ...process.env,
    TEST_RESULTS_GLOB: junitPath,
    EVIDENCE_DIR: dir,
    REQ_MAPPING_FILE: reqPath,
    RUNNER_OS: 'Linux',
  };

  await execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env });

  const outDir = path.join('artifacts', 'linux');
  const std = await fs.readFile(path.join(outDir, 'summary-standard.md'), 'utf8');
  assert.match(std, /REQ-1/);
  const integ = await fs.readFile(path.join(outDir, 'summary-integration.md'), 'utf8');
  assert.match(integ, /REQ-2/);
  const traceStdExists = await fs.stat(path.join(outDir, 'traceability-standard.md')).then(() => true, () => false);
  const traceIntegExists = await fs.stat(path.join(outDir, 'traceability-integration.md')).then(() => true, () => false);
  assert.strictEqual(traceStdExists && traceIntegExists, true);

  await fs.rm(dir, { recursive: true, force: true });
  await fs.rm('artifacts', { recursive: true, force: true });
});
