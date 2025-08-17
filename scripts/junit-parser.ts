import { parseStringPromise } from 'xml2js';

export interface JUnitTestCase {
  name: string;
  status: 'Passed' | 'Failed' | 'Skipped';
  classname?: string;
  assertions?: string;
  time: number;
  skippedMessage?: string;
  requirements: string[];
  attributes: Record<string, string>;
}

export interface JUnitTestSuite {
  attributes: Record<string, string>;
  properties: Record<string, string>;
  testcases: JUnitTestCase[];
}

export interface JUnitReport {
  attributes: Record<string, string>;
  suites: JUnitTestSuite[];
}

function extractAttributes(obj: any): Record<string, string> {
  const attrs: Record<string, string> = {};
  for (const [k, v] of Object.entries(obj ?? {})) {
    if (typeof v === 'string') attrs[k] = v;
  }
  return attrs;
}

export async function parseJUnit(xml: string): Promise<JUnitReport> {
  const parsed = await parseStringPromise(xml, { explicitArray: false, mergeAttrs: true });
  const root = parsed.testsuites ?? parsed.testsuite;
  const reportAttrs = extractAttributes(root);
  const rawSuites = root.testsuite
    ? Array.isArray(root.testsuite)
      ? root.testsuite
      : [root.testsuite]
    : root.testcase
    ? [root]
    : [];
  const suites: JUnitTestSuite[] = rawSuites.map((s: any) => {
    const suiteAttrs = extractAttributes(s);
    const props: Record<string, string> = {};
    const properties = s.properties?.property;
    const list = Array.isArray(properties) ? properties : properties ? [properties] : [];
    for (const p of list) {
      if (p.name && (p.value || p._)) {
        props[p.name] = p.value ?? p._ ?? '';
      }
    }
    const rawCases = s.testcase ? (Array.isArray(s.testcase) ? s.testcase : [s.testcase]) : [];
    const testcases: JUnitTestCase[] = rawCases.map((tc: any) => {
      const tcAttrs = extractAttributes(tc);
      const name = tc.name ?? 'unknown';
      const classname = tc.classname;
      const assertions = tc.assertions;
      const time = parseFloat(tc.time ?? '0');
      let status: 'Passed' | 'Failed' | 'Skipped' = 'Passed';
      if (tc.failure || tc.error) status = 'Failed';
      else if (tc.skipped) status = 'Skipped';
      const skippedMessage = tc.skipped?.message ?? tc.skipped?._;
      const reqMatches = [...name.matchAll(/\[(REQ-\d+)\]/gi)].map((m) => m[1].toUpperCase());
      const requirements = Array.from(new Set(reqMatches));
      return { name, status, classname, assertions, time, skippedMessage, requirements, attributes: tcAttrs };
    });
    return { attributes: suiteAttrs, properties: props, testcases };
  });
  return { attributes: reportAttrs, suites };
}

export function summarize(report: JUnitReport) {
  const byRequirement: Record<string, { passed: number; failed: number; skipped: number }> = {};
  const bySuite: Record<string, { passed: number; failed: number; skipped: number }> = {};
  for (const suite of report.suites) {
    const sName = suite.attributes.name || 'unknown';
    if (!bySuite[sName]) bySuite[sName] = { passed: 0, failed: 0, skipped: 0 };
    for (const tc of suite.testcases) {
      if (!bySuite[sName]) bySuite[sName] = { passed: 0, failed: 0, skipped: 0 };
      bySuite[sName][tc.status.toLowerCase() as 'passed' | 'failed' | 'skipped']++;
      for (const r of tc.requirements) {
        if (!byRequirement[r]) byRequirement[r] = { passed: 0, failed: 0, skipped: 0 };
        byRequirement[r][tc.status.toLowerCase() as 'passed' | 'failed' | 'skipped']++;
      }
    }
  }
  return { byRequirement, bySuite };
}

export function buildTraceability(report: JUnitReport) {
  const rows: {
    requirement: string;
    testcase: string;
    status: string;
    time: number;
    host?: string;
    skippedMessage?: string;
  }[] = [];
  for (const suite of report.suites) {
    const host = suite.properties['machine-name'];
    for (const tc of suite.testcases) {
      for (const req of tc.requirements) {
        rows.push({
          requirement: req,
          testcase: tc.name,
          status: tc.status,
          time: tc.time,
          host,
          skippedMessage: tc.skippedMessage,
        });
      }
    }
  }
  return rows;
}

export function validate(report: JUnitReport) {
  const warnings: string[] = [];
  const requiredRoot = ['name', 'tests', 'errors', 'failures', 'disabled', 'time'];
  for (const f of requiredRoot) {
    if (!(f in report.attributes)) warnings.push(`missing testsuites attribute: ${f}`);
  }
  for (const suite of report.suites) {
    const reqSuite = ['name', 'tests', 'errors', 'failures', 'hostname', 'id', 'skipped', 'disabled', 'package', 'time'];
    for (const f of reqSuite) {
      if (!(f in suite.attributes)) warnings.push(`missing testsuite attribute: ${f}`);
    }
    for (const tc of suite.testcases) {
      if (!tc.name) warnings.push('missing testcase name');
      if (typeof tc.time !== 'number') warnings.push('missing testcase time');
    }
  }
  return warnings;
}
