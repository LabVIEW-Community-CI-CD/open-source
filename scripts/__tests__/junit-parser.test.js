import test from 'node:test';
import assert from 'node:assert/strict';
import { parseJUnit, summarize, buildTraceability, validate } from '../junit-parser.ts';

const xml = `<?xml version="1.0" encoding="utf-8"?>
<testsuites name="Root" tests="2" errors="1" failures="0" disabled="0" time="1.23">
  <testsuite name="SuiteA" tests="1" errors="0" failures="0" skipped="0" disabled="0" hostname="hostA" id="0" package="pkgA" time="0.5">
    <properties>
      <property name="machine-name" value="hostA" />
      <property name="os-version" value="Ubuntu" />
    </properties>
    <testcase name="pass case [REQ-028]" classname="ClsA" assertions="1" time="0.1" extra="1" />
  </testsuite>
  <testsuite name="SuiteB" tests="1" errors="0" failures="0" skipped="1" disabled="0" hostname="hostB" id="1" package="pkgB" time="0.7">
    <properties>
      <property name="machine-name" value="hostB" />
    </properties>
    <testcase name="skip case [REQ-028]" classname="ClsB" assertions="1" time="0.2">
      <skipped message="no reason" />
    </testcase>
  </testsuite>
</testsuites>`;

const xmlMissing = `<testsuites><testsuite><testcase /></testsuite></testsuites>`;

const xmlExtra = `<testsuites name="X" tests="0" errors="0" failures="0" disabled="0" time="0"><testsuite name="S" tests="0" errors="0" failures="0" skipped="0" disabled="0" hostname="h" id="1" package="p" time="0"><testcase name="t" foo="bar" time="0"/></testsuite></testsuites>`;
const xmlBad = `<testsuites><testsuite>`;

test('[REQ-023] parses nested JUnit structures', async () => {
  const report = await parseJUnit(xml);
  assert.strictEqual(report.suites.length, 2);
  assert.strictEqual(report.suites[0].testcases.length, 1);
});

test('[REQ-024] captures root testsuites attributes', async () => {
  const report = await parseJUnit(xml);
  assert.strictEqual(report.attributes.name, 'Root');
  assert.strictEqual(report.attributes.tests, '2');
  assert.strictEqual(report.attributes.errors, '1');
});

test('[REQ-025] captures testsuite attributes', async () => {
  const report = await parseJUnit(xml);
  assert.strictEqual(report.suites[0].attributes.hostname, 'hostA');
  assert.strictEqual(report.suites[1].attributes.skipped, '1');
});

test('[REQ-026] captures suite properties', async () => {
  const report = await parseJUnit(xml);
  assert.strictEqual(report.suites[0].properties['os-version'], 'Ubuntu');
});

test('[REQ-027] captures testcase attributes and skipped message', async () => {
  const report = await parseJUnit(xml);
  const tc = report.suites[1].testcases[0];
  assert.strictEqual(tc.classname, 'ClsB');
  assert.strictEqual(tc.skippedMessage, 'no reason');
});

test('[REQ-028] extracts requirement identifiers', async () => {
  const report = await parseJUnit(xml);
  const ids = report.suites.flatMap((s) => s.testcases.flatMap((t) => t.requirements));
  assert.deepStrictEqual(ids, ['REQ-028', 'REQ-028']);
});

test('[REQ-029] aggregates status by requirement and suite', async () => {
  const report = await parseJUnit(xml);
  const sums = summarize(report);
  assert.strictEqual(sums.byRequirement['REQ-028'].skipped, 1);
  assert.strictEqual(sums.bySuite['SuiteA'].passed, 1);
});

test('[REQ-030] builds traceability matrix with skipped reasons', async () => {
  const report = await parseJUnit(xml);
  const matrix = buildTraceability(report);
  const skipped = matrix.find((m) => m.status === 'Skipped');
  assert.ok(skipped && skipped.skippedMessage === 'no reason');
});

test('[REQ-031] validates missing fields', async () => {
  const report = await parseJUnit(xmlMissing);
  const warnings = validate(report);
  assert.ok(warnings.length > 0);
});

test('[REQ-032] preserves unknown attributes', async () => {
  const report = await parseJUnit(xmlExtra);
  assert.strictEqual(report.suites[0].testcases[0].attributes.foo, 'bar');
});

test('[REQ-033] throws error for malformed XML', async () => {
  await assert.rejects(() => parseJUnit(xmlBad), { message: 'Invalid JUnit XML' });
});
