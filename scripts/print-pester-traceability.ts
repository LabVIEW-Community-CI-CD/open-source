#!/usr/bin/env tsx
import path from 'path';
import { glob } from 'glob';
import { collectTestCases } from './summary/tests.ts';
import { buildTable } from './utils/markdown.ts';

async function main() {
  const overrideDir = process.env.PESTER_JUNIT_PATH;
  let junitFiles: string[] = [];
  if (overrideDir) {
    junitFiles = await glob(path.join(overrideDir, 'pester-junit.xml'));
  } else {
    const matches = await glob(
      '{artifacts/pester-junit-*/pester-junit.xml,downloaded-artifacts/test-results-pester-*/pester-junit.xml}'
    );
    if (matches.length > 0) {
      const latestDir = matches
        .map((f) => path.dirname(f))
        .sort()
        .pop()!;
      junitFiles = matches.filter((f) => path.dirname(f) === latestDir);
    }
  }
  if (junitFiles.length === 0) {
    console.warn('No JUnit files found');
    process.exit(1);
  }
  const tests = [];
  for (const file of junitFiles) {
    const dir = path.dirname(file);
    const ts = await collectTestCases([file], dir, process.env.RUNNER_OS);
    tests.push(...ts);
  }
  const groups: Map<string, typeof tests> = new Map();
  for (const t of tests) {
    const owner = t.owner || 'Unassigned';
    if (!groups.has(owner)) groups.set(owner, []);
    groups.get(owner)!.push(t);
  }
  const lines: string[] = [];
  const sortedOwners = Array.from(groups.keys()).sort();
  for (const owner of sortedOwners) {
    const tlist = groups.get(owner)!;
    const header = ['Requirement', 'Test ID', 'Status', 'Duration (s)', 'Owner', 'Evidence'];
    const rows: string[][] = [];
    for (const t of tlist) {
      const evidence = t.evidence ? `[link](${t.evidence})` : '';
      rows.push([
        t.requirements.join(', '),
        t.id,
        t.status,
        t.duration.toFixed(3),
        t.owner ?? owner,
        evidence,
      ]);
    }
    const content = buildTable(header, rows);
    lines.push(`<details><summary>${owner}</summary>\n\n${content}\n\n</details>`);
  }
  console.log(lines.join('\n\n'));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
