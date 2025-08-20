import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { fileURLToPath } from 'node:url';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import AdmZip from 'adm-zip';
import { collectTestCases } from '../summary/tests.ts';
import { loadRequirements, mapToRequirements } from '../summary/requirements.ts';
import { groupToMarkdown, summaryToMarkdown, requirementsSummaryToMarkdown, buildSummary, computeStatusCounts } from '../summary/index.ts';
import { writeErrorSummary } from '../error-handler.ts';

const fileUrl = new URL('../generate-ci-summary.ts', import.meta.url);
const summaryUrl = new URL('../summary/index.ts', import.meta.url);
const requirementsUrl = new URL('../summary/requirements.ts', import.meta.url);

test('generate-ci-summary features', async () => {
  const content = await fs.readFile(fileUrl, 'utf8');
  const summaryContent = await fs.readFile(summaryUrl, 'utf8');
  const reqContent = await fs.readFile(requirementsUrl, 'utf8');
  assert.match(content, /TEST_RESULTS_GLOBS/);
  assert.match(reqContent, /<redacted>/);
  assert.match(summaryContent, /<details><summary>/);
  assert.match(content, /artifacts\/\*\*\/\*junit\*\.xml/);
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

test('writeErrorSummary appends error details to summary file', async () => {
  const tmp = new URL('./error-summary.md', import.meta.url);
  await fs.rm(tmp, { force: true });
  process.env.GITHUB_STEP_SUMMARY = fileURLToPath(tmp);
  const err = new Error('kaboom');
  await writeErrorSummary(err);
  const content = await fs.readFile(tmp, 'utf8');
  assert.match(content, /kaboom/);
  await fs.rm(tmp, { force: true });
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

test('loadRequirements logs warning on invalid JSON', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'req-'));
  const badPath = path.join(dir, 'bad.json');
  await fs.writeFile(badPath, '{');
  const tmpSummary = path.join(dir, 'summary.md');
  process.env.GITHUB_STEP_SUMMARY = tmpSummary;
  let warned = '';
  const origWarn = console.warn;
  console.warn = (msg, ...args) => {
    warned += String(msg);
    if (args.length) warned += ' ' + args.join(' ');
  };
  const { map, meta } = await loadRequirements(badPath);
  console.warn = origWarn;
  delete process.env.GITHUB_STEP_SUMMARY;
  await fs.rm(dir, { recursive: true, force: true });
  assert.deepEqual(map, {});
  assert.deepEqual(meta, {});
  assert.match(warned, /Failed to load requirements mapping/);
});

test('loadRequirements warns and skips invalid entries', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'req-'));
  const req = {
    requirements: [
      { id: 'REQ-1', tests: ['good'] },
      { tests: ['missing id'] },
      { id: 'REQ-3', tests: 'not-array' },
    ],
  };
  const reqPath = path.join(dir, 'req.json');
  await fs.writeFile(reqPath, JSON.stringify(req));
  let warned = '';
  const origWarn = console.warn;
  console.warn = (msg) => {
    warned += String(msg);
  };
  const { map, meta } = await loadRequirements(reqPath);
  console.warn = origWarn;
  await fs.rm(dir, { recursive: true, force: true });
  assert.match(warned, /Invalid requirement entry/);
  assert.strictEqual('good' in map, true);
  assert.strictEqual('missing id' in map, false);
  assert.strictEqual('not-array' in map, false);
  assert.deepEqual(Object.keys(meta), ['REQ-1']);
});

test('loadRequirements merges multiple files', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'multi-'));
  const req1 = { requirements: [{ id: 'REQ-A', tests: ['a'] }] };
  const req2 = { requirements: [{ id: 'REQ-B', tests: ['b'] }] };
  const p1 = path.join(dir, 'r1.json');
  const p2 = path.join(dir, 'r2.json');
  await fs.writeFile(p1, JSON.stringify(req1));
  await fs.writeFile(p2, JSON.stringify(req2));
  const { map, meta } = await loadRequirements([p1, p2]);
  await fs.rm(dir, { recursive: true, force: true });
  assert.deepEqual(map.a.requirements, ['REQ-A']);
  assert.deepEqual(map.b.requirements, ['REQ-B']);
  assert.deepEqual(Object.keys(meta).sort(), ['REQ-A', 'REQ-B']);
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

test('collectTestCases uses evidence property and falls back to directory scan', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'evidence-'));
  const xmlProp = `<testsuite><testcase name="alpha" time="0"><properties><property name="evidence" value="http://ci/example.log"/></properties></testcase></testsuite>`;
  const propPath = path.join(dir, 'junit1.xml');
  await fs.writeFile(propPath, xmlProp);
  const xmlFallback = `<testsuite><testcase name="beta" time="0"/></testsuite>`;
  const fallbackPath = path.join(dir, 'junit2.xml');
  await fs.writeFile(fallbackPath, xmlFallback);
  await fs.writeFile(path.join(dir, 'beta.txt'), 'x');

  const testsProp = await collectTestCases([propPath], dir, 'linux');
  assert.strictEqual(testsProp[0].evidence, 'http://ci/example.log');
  const testsFallback = await collectTestCases([fallbackPath], dir, 'linux');
  assert.strictEqual(testsFallback[0].evidence, path.join('evidence', 'beta.txt'));

  await fs.rm(dir, { recursive: true, force: true });
});

test('collectTestCases captures requirement property', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'reqprop-'));
  const xml = `<testsuite><testcase name="gamma" time="0"><properties><property name="requirement" value="REQ-123"/></properties></testcase></testsuite>`;
  const xmlPath = path.join(dir, 'junit.xml');
  await fs.writeFile(xmlPath, xml);
  const tests = await collectTestCases([xmlPath], dir, 'linux');
  assert.deepStrictEqual(tests[0].requirements, ['REQ-123']);
  await fs.rm(dir, { recursive: true, force: true });
});

test('groupToMarkdown omits numeric identifiers', () => {
  const groups = [{
    id: 'REQ-XYZ',
    tests: [
      { id: 'alpha', name: 'Alpha', status: 'Passed', duration: 0, requirements: [] },
      { id: 'beta', name: 'Beta', status: 'Failed', duration: 0, requirements: [] },
    ],
  }];
  const md = groupToMarkdown(groups);
  assert.doesNotMatch(md, /\| ID \|/);
  assert.match(md, /\| Requirement \| Test ID \| Status \| Duration \(s\) \| Owner \| Evidence \|/);
  assert.match(md, /\| REQ-XYZ \| alpha \| Passed \|/);
  assert.match(md, /\| REQ-XYZ \| beta \| Failed \|/);
});

test('groupToMarkdown supports optional limit for truncation', () => {
  const groups = [{
    id: 'REQ-XYZ',
    tests: [
      { id: 'alpha', name: 'Alpha', status: 'Passed', duration: 0, requirements: [] },
      { id: 'beta', name: 'Beta', status: 'Failed', duration: 0, requirements: [] },
      { id: 'gamma', name: 'Gamma', status: 'Skipped', duration: 0, requirements: [] },
    ],
  }];
  const truncated = groupToMarkdown(groups, 2);
  assert.match(truncated, /Truncated/);
  assert.strictEqual(truncated.includes('gamma'), false);

  const full = groupToMarkdown(groups);
  assert.doesNotMatch(full, /Truncated/);
  assert.ok(full.includes('gamma'));
});

test('requirementsSummaryToMarkdown escapes pipes in description', () => {
  const groups = [
    { id: 'REQ-1', description: 'Alpha | Beta', tests: [] },
  ];
  const md = requirementsSummaryToMarkdown(groups);
  assert.ok(md.includes('| Requirement ID | Description | Owner | Total Tests | Passed | Failed | Skipped | Pass Rate (%) |'));
  assert.ok(md.includes('| REQ-1 | Alpha \\| Beta |  | 0 | 0 | 0 | 0 | 0.00 |'));
});

test('computeStatusCounts tallies test statuses', () => {
  const tests = [
    { id: '1', name: 'a', status: 'Passed', duration: 0, requirements: [] },
    { id: '2', name: 'b', status: 'Failed', duration: 0, requirements: [] },
    { id: '3', name: 'c', status: 'Skipped', duration: 0, requirements: [] },
    { id: '4', name: 'd', status: 'Passed', duration: 0, requirements: [] },
  ];
  const counts = computeStatusCounts(tests);
  assert.deepEqual(counts, { total: 4, passed: 2, failed: 1, skipped: 1 });
});

test('summaryToMarkdown sorts OS alphabetically and escapes special characters', () => {
  const totals = {
    overall: { passed: 2, failed: 0, skipped: 0, duration: 3, rate: 100 },
    byOs: {
      'win|dos': { passed: 1, failed: 0, skipped: 0, duration: 1, rate: 100 },
      linux: { passed: 1, failed: 0, skipped: 0, duration: 2, rate: 100 },
    },
  };
  const md = summaryToMarkdown(totals);
  assert.match(md, /\| OS \| Passed \| Failed \| Skipped \| Duration \(s\) \| Pass Rate \(%\) \|/);
  assert.ok(md.includes('| win\\|dos | 1 | 0 | 0 | 1.00 | 100.00 |'));
  const linuxIdx = md.indexOf('| linux |');
  const winIdx = md.indexOf('| win\\|dos |');
  assert.ok(linuxIdx > -1 && winIdx > linuxIdx);
});

test('summaryToMarkdown handles no tests', () => {
  const totals = { overall: { passed: 0, failed: 0, skipped: 0, duration: 0, rate: 0 }, byOs: {} };
  const md = summaryToMarkdown(totals);
  assert.ok(md.includes('| overall | 0 | 0 | 0 | 0.00 | 0.00 |'));
  assert.strictEqual(md.includes('| linux |'), false);
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
    TEST_RESULTS_GLOBS: junitPath,
    EVIDENCE_DIR: tmp,
    RUNNER_OS: 'Windows',
  };

  await execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env });

  const outDir = path.join('artifacts', 'windows');
  const exists = await fs.stat(path.join(outDir, 'traceability.json')).then(() => true, () => false);
  assert.strictEqual(exists, true);
  const summary = await fs.readFile(path.join(outDir, 'summary.md'), 'utf8');
  assert.match(summary, /\| windows \| 1 \| 0 \| 0 \|/);
  const reqSummary = await fs.readFile(path.join(outDir, 'requirements-summary.md'), 'utf8');
  assert.match(reqSummary, /### Requirement Summary/);
  assert.match(reqSummary, /Unmapped/);
  assert.match(reqSummary, /### Requirement Testcases/);
  assert.match(reqSummary, /\| Unmapped \| foo \| Passed \|/);

  await fs.rm(tmp, { recursive: true, force: true });
  await fs.rm('artifacts', { recursive: true, force: true });
});

test('skips invalid JUnit files and still generates summary', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'badjunit-'));
  const goodXml = '<testsuite><testcase name="good" time="0"/></testsuite>';
  const badXml = '<testsuite><testcase name="bad"></testsuite>';
  const goodPath = path.join(dir, 'good.xml');
  const badPath = path.join(dir, 'bad.xml');
  await fs.writeFile(goodPath, goodXml);
  await fs.writeFile(badPath, badXml);

  await fs.rm('artifacts', { recursive: true, force: true });

  const env = {
    ...process.env,
    TEST_RESULTS_GLOBS: `${goodPath} ${badPath}`,
    EVIDENCE_DIR: dir,
    RUNNER_OS: 'Linux',
  };

  const { stderr } = await execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env });

  const outDir = path.join('artifacts', 'linux');
  const summary = await fs.readFile(path.join(outDir, 'summary.md'), 'utf8');
  assert.match(summary, /\| linux \| 1 \| 0 \| 0 \|/);
  const trace = await fs.readFile(path.join(outDir, 'traceability.md'), 'utf8');
  assert.match(trace, /good/);
  assert.strictEqual(trace.includes('bad'), false);
  assert.match(stderr, /Failed to parse JUnit file/);

  await fs.rm(dir, { recursive: true, force: true });
  await fs.rm('artifacts', { recursive: true, force: true });
});

test('warns when all tests are unmapped', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'unmapped-'));
  const junitPath = path.join(dir, 'junit.xml');
  await fs.writeFile(junitPath, '<testsuite><testcase name="foo" time="0"/></testsuite>');
  const reqPath = path.join(dir, 'req.json');
  await fs.writeFile(reqPath, JSON.stringify({ requirements: [] }));

  await fs.rm('artifacts', { recursive: true, force: true });

  const env = {
    ...process.env,
    TEST_RESULTS_GLOBS: junitPath,
    EVIDENCE_DIR: dir,
    REQ_MAPPING_FILE: reqPath,
    RUNNER_OS: 'Linux',
  };

  const { stderr } = await execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env });
  assert.match(stderr, /All tests are unmapped/);

  await fs.rm(dir, { recursive: true, force: true });
  await fs.rm('artifacts', { recursive: true, force: true });
});

test('errors when strict unmapped mode enabled', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'unmapped-'));
  const junitPath = path.join(dir, 'junit.xml');
  await fs.writeFile(junitPath, '<testsuite><testcase name="foo" time="0"/></testsuite>');
  const reqPath = path.join(dir, 'req.json');
  await fs.writeFile(reqPath, JSON.stringify({ requirements: [] }));

  await fs.rm('artifacts', { recursive: true, force: true });

  const env = {
    ...process.env,
    TEST_RESULTS_GLOBS: junitPath,
    EVIDENCE_DIR: dir,
    REQ_MAPPING_FILE: reqPath,
    RUNNER_OS: 'Linux',
    REQUIRE_REQUIREMENTS_MAPPING: '1',
  };

  await assert.rejects(
    execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env }),
    /All tests are unmapped/,
  );

  await fs.rm(dir, { recursive: true, force: true });
  await fs.rm('artifacts', { recursive: true, force: true });
});

test('ignores stale JUnit files outside artifacts path', async () => {
  await fs.rm('artifacts', { recursive: true, force: true });
  const freshDir = path.join('artifacts', 'current');
  await fs.mkdir(freshDir, { recursive: true });
  const freshXml = '<testsuite><testcase name="fresh" time="0"/></testsuite>';
  await fs.writeFile(path.join(freshDir, 'junit.xml'), freshXml);
  const stalePath = path.join('stale-junit.xml');
  await fs.writeFile(stalePath, '<testsuite><testcase name="stale" time="0"/></testsuite>');

  const env = { ...process.env, RUNNER_OS: 'Linux' };
  await execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env });

  const trace = await fs.readFile(path.join('artifacts', 'linux', 'traceability.md'), 'utf8');
  assert.match(trace, /fresh/);
  assert.strictEqual(trace.includes('stale'), false);

  await fs.rm('artifacts', { recursive: true, force: true });
  await fs.rm(stalePath, { force: true });
});

test('throws when no JUnit files found and strict mode enabled', async () => {
  await fs.rm('artifacts', { recursive: true, force: true });
  const env = { ...process.env, REQUIRE_TEST_RESULTS: '1', RUNNER_OS: 'Linux' };
  await assert.rejects(
    execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env }),
    /No JUnit files found/,
  );
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
    TEST_RESULTS_GLOBS: junitPath,
    EVIDENCE_DIR: dir,
    REQ_MAPPING_FILE: reqPath,
    RUNNER_OS: 'Linux',
  };

  await execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env });

  const outDir = path.join('artifacts', 'linux');
  const std = await fs.readFile(path.join(outDir, 'summary-standard.md'), 'utf8');
  assert.match(std, /traceability-standard.md/);
  const integ = await fs.readFile(path.join(outDir, 'summary-integration.md'), 'utf8');
  assert.match(integ, /traceability-integration.md/);
  const traceStd = await fs.readFile(path.join(outDir, 'traceability-standard.md'), 'utf8');
  assert.match(traceStd, /REQ-1/);
  const traceInteg = await fs.readFile(path.join(outDir, 'traceability-integration.md'), 'utf8');
  assert.match(traceInteg, /REQ-2/);

  await fs.rm(dir, { recursive: true, force: true });
  await fs.rm('artifacts', { recursive: true, force: true });
});

test('handles zipped JUnit artifacts', async () => {
  const tmp = await fs.mkdtemp(path.join(os.tmpdir(), 'zip-'));
  const zip = new AdmZip();
  const xml = '<testsuite><testcase classname="Dispatcher.Tests" name="zip" time="0"/></testsuite>';
  zip.addFile('junit.xml', Buffer.from(xml));
  const zipPath = path.join(tmp, 'junit.zip');
  zip.writeZip(zipPath);
  await fs.mkdir(path.join(tmp, 'evidence'));

  await fs.rm('artifacts', { recursive: true, force: true });

  const reqPath = fileURLToPath(new URL('../../requirements.json', import.meta.url));
  const dispPath = fileURLToPath(new URL('../../dispatchers.json', import.meta.url));
  const env = {
    ...process.env,
    TEST_RESULTS_GLOBS: zipPath,
    EVIDENCE_DIR: path.join(tmp, 'evidence'),
    REQ_MAPPING_FILE: reqPath,
    DISPATCHER_REGISTRY: dispPath,
    RUNNER_OS: 'Linux',
  };

  await execFileP('node_modules/.bin/tsx', ['scripts/generate-ci-summary.ts'], { env });

  const summary = await fs.readFile(path.join('artifacts', 'linux', 'requirements-summary.md'), 'utf8');
  assert.match(summary, /REQ-001/);

  await fs.rm('artifacts', { recursive: true, force: true });
  await fs.rm(tmp, { recursive: true, force: true });
});
