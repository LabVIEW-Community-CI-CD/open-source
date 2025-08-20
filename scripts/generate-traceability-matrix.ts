#!/usr/bin/env tsx
import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';
import { RequirementGroup } from './summary/index.ts';
import { buildTable } from './utils/markdown.ts';

async function main() {
  const traceabilityPath = process.argv[2] || path.join('artifacts', 'linux', 'traceability.json');
  const raw = await fs.readFile(traceabilityPath, 'utf8');
  const data: { requirements: RequirementGroup[] } = JSON.parse(raw);
  const groups = data.requirements;

  const logOutput = execSync('git log --pretty=format:%H\\|%s', { encoding: 'utf8' });
  const commitMap: Record<string, { sha: string; msg: string }[]> = {};
  const regex = /(REQ[A-Z]*-\d+)/g;
  for (const line of logOutput.split(/\r?\n/)) {
    if (!line.trim()) continue;
    const [sha, message] = line.split('|');
    const matches = message.match(regex);
    if (!matches) continue;
    for (const req of matches) {
      if (!commitMap[req]) commitMap[req] = [];
      commitMap[req].push({ sha, msg: message });
    }
  }

  const baseUrl = process.env.GITHUB_SERVER_URL && process.env.GITHUB_REPOSITORY
    ? `${process.env.GITHUB_SERVER_URL}/${process.env.GITHUB_REPOSITORY}`
    : undefined;

  const header = ['Requirement', 'Description', 'Commits', 'Tests'];
  const rows: string[][] = [];
  for (const g of groups) {
    const commits = (commitMap[g.id] || [])
      .map(c => baseUrl ? `[${c.sha.slice(0,7)}](${baseUrl}/commit/${c.sha})` : c.sha.slice(0,7))
      .join('<br>');
    const tests = g.tests.map(t => `${t.id} (${t.status})`).join('<br>');
    rows.push([g.id, g.description ?? '', commits, tests]);
  }
  const markdown = `### Requirement Traceability Matrix\n\n${buildTable(header, rows)}\n`;
  const outDir = path.dirname(traceabilityPath);
  await fs.writeFile(path.join(outDir, 'traceability-matrix.md'), markdown);
  console.log(markdown);
}

main().catch(err => {
  console.error(err);
  process.exit(1);
});
