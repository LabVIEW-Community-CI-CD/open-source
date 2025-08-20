import fs from 'fs/promises';
import path from 'path';
import { TestCase } from './index.ts';
import { parseJUnit } from '../junit-parser.ts';

export function normalizeTestId(id: string): string {
  return id
    .replace(/\[[^\]]*\]\s*/g, '')
    .toLowerCase()
    .replace(/::/g, '-')
    .replace(/\s+/g, '-');
}

export async function collectTestCases(files: string[], evidenceDir: string, os?: string): Promise<TestCase[]> {
  const evidenceFiles = await fs.readdir(evidenceDir).catch(() => []);
  const tests: TestCase[] = [];
  const osType = (os ?? process.env.RUNNER_OS ?? 'unknown').toLowerCase();
  for (const file of files) {
    let report;
    try {
      const xml = await fs.readFile(file, 'utf8');
      report = await parseJUnit(xml);
    } catch (err) {
      console.warn('Failed to parse JUnit file:', file, err);
      continue;
    }
    for (const suite of report.suites) {
      for (const tc of suite.testcases) {
        const id = normalizeTestId(tc.name);
        const test: TestCase = {
          id,
          name: tc.name,
          className: tc.classname,
          status: tc.status,
          duration: tc.time,
          requirements: [...tc.requirements],
          os: osType,
        };
        const props = tc.properties;
        const ownerVal = props['owner'] ?? props['machine-name'];
        if (ownerVal) test.owner = ownerVal;
        const evidenceVal = props['evidence'] ?? props['attachment'] ?? props['ci_link'];
        if (evidenceVal) test.evidence = evidenceVal;
        if (!test.evidence) {
          const evidence = evidenceFiles.find((f) => f.startsWith(id) || f.startsWith(id + '.'));
          if (evidence) test.evidence = path.join('evidence', evidence);
        }
        if (!test.owner) {
          const ownerMatch = tc.name.match(/\[Owner:([^\]]+)\]/i);
          if (ownerMatch) test.owner = ownerMatch[1];
        }
        tests.push(test);
      }
    }
  }
  return tests;
}

