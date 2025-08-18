import test from 'node:test';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';

const execFileP = promisify(execFile);

const fixtureDir = fileURLToPath(new URL('./fixtures', import.meta.url));
const rootDir = fileURLToPath(new URL('../..', import.meta.url));

test('groups owners and includes requirements and evidence', async () => {
  const env = { ...process.env, RUNNER_OS: 'Linux' };
  const tsxPath = path.join(rootDir, 'node_modules/.bin/tsx');
  const scriptPath = '../../print-pester-traceability.ts';
  const { stdout } = await execFileP(tsxPath, [scriptPath], { cwd: fixtureDir, env });

  // ensure details sections for each owner
  assert.match(stdout, /<details><summary>alice<\/summary>/);
  assert.match(stdout, /<details><summary>bob<\/summary>/);

  // owners grouped correctly
  const aliceSection = stdout.match(/<details><summary>alice<\/summary>[\s\S]*?<\/details>/)[0];
  const bobSection = stdout.match(/<details><summary>bob<\/summary>[\s\S]*?<\/details>/)[0];
  assert(aliceSection.includes('Alpha') && aliceSection.includes('Gamma'));
  assert(!aliceSection.includes('Beta'));
  assert(bobSection.includes('Beta'));
  assert(!bobSection.includes('Alpha') && !bobSection.includes('Gamma'));

  // requirement IDs and evidence links
  assert.match(aliceSection, /Alpha \| REQ-123 \| Passed \| \[link\]\(http:\/\/example.com\/alpha.log\)/);
  assert.match(aliceSection, /Gamma \| REQ-789 \| Passed \| \[link\]\(http:\/\/example.com\/gamma.log\)/);
  assert.match(bobSection, /Beta \| REQ-456 \| Passed \| \[link\]\(http:\/\/example.com\/beta.log\)/);
});
