#!/usr/bin/env tsx
import fs from 'fs/promises';
import path from 'path';
import { execSync } from 'child_process';

async function main() {
  const reqFile = process.env.REQ_MAPPING_FILE || 'requirements.json';
  const traceFile =
    process.env.TRACEABILITY_FILE ||
    path.join('artifacts', (process.env.RUNNER_OS || 'linux').toLowerCase(), 'traceability.json');

  const reqRaw = JSON.parse(await fs.readFile(reqFile, 'utf8'));
  const reqIds: string[] = (reqRaw.requirements || []).map((r: any) => r.id);

  const traceRaw = JSON.parse(await fs.readFile(traceFile, 'utf8'));
  const groups: any[] = traceRaw.requirements || [];

  const missing: string[] = [];
  for (const id of reqIds) {
    const g = groups.find((gr) => gr.id === id);
    if (!g || !Array.isArray(g.tests) || g.tests.length === 0) {
      missing.push(id);
    }
  }
  if (missing.length > 0) {
    console.error(`No tests executed for requirements: ${missing.join(', ')}`);
    process.exit(1);
  }

  const commitMsg = execSync('git log -1 --pretty=%B', { encoding: 'utf8' });
  const prBody = process.env.PR_BODY || process.env.GITHUB_PR_BODY || '';
  const combined = commitMsg + '\n' + prBody;
  if (!/(REQ[A-Z]*-\d+)/.test(combined)) {
    console.error('No requirement references found in commit message or PR body.');
    process.exit(1);
  }

  console.log('Traceability checks passed.');
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
