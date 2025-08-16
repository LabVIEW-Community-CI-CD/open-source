import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';
import { collectTestCases, loadRequirements, mapToRequirements } from '../generate-ci-summary.ts';
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
