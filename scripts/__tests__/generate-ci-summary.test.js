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
  const tests = await collectTestCases([xmlPath], dir);
  const reqPath = fileURLToPath(new URL('../../requirements.json', import.meta.url));
  const { map, meta } = await loadRequirements(reqPath);
  const groups = mapToRequirements(tests, map, meta);
  const req = groups.find((g) => g.id === 'REQ-001');
  assert(req && req.tests.some((t) => t.className === 'Dispatcher.Tests'));
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

  await fs.rm(tmp, { recursive: true, force: true });
  await fs.rm('artifacts', { recursive: true, force: true });
});
