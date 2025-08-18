#!/usr/bin/env tsx
import path from 'path';
import { glob } from 'glob';
import { collectTestCases } from './generate-ci-summary.ts';

async function main() {
  const junitFiles = await glob('downloaded/pester-junit-*/pester-junit.xml');
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
    const table = ['| Test | Requirements | Status | Evidence |', '| --- | --- | --- | --- |'];
    for (const t of tlist) {
      const reqs = t.requirements.join(', ');
      const evidence = t.evidence ? `[link](${t.evidence})` : '';
      table.push(`| ${t.name} | ${reqs} | ${t.status} | ${evidence} |`);
    }
    const content = table.join('\n');
    lines.push(`<details><summary>${owner}</summary>\n\n${content}\n\n</details>`);
  }
  console.log(lines.join('\n\n'));
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
