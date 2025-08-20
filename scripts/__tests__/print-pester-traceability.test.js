import test from 'node:test';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';

const execFileP = promisify(execFile);

const fixtureDir = fileURLToPath(new URL('./fixtures', import.meta.url));
const rootDir = fileURLToPath(new URL('../..', import.meta.url));
const scriptFile = path.join(rootDir, 'scripts/print-pester-traceability.ts');

test('groups owners and includes requirements and evidence', async () => {
  const env = { ...process.env, RUNNER_OS: 'Linux' };
  const tsxPath = path.join(rootDir, 'node_modules/.bin/tsx');
  const { stdout } = await execFileP(tsxPath, [scriptFile], { cwd: fixtureDir, env });

  // ensure details sections for each owner
  assert.match(stdout, /<details><summary>alice<\/summary>/);
  assert.match(stdout, /<details><summary>bob<\/summary>/);

  // owners grouped correctly
  const aliceSection = stdout.match(/<details><summary>alice<\/summary>[\s\S]*?<\/details>/)[0];
  const bobSection = stdout.match(/<details><summary>bob<\/summary>[\s\S]*?<\/details>/)[0];
  assert(aliceSection.includes('alpha') && aliceSection.includes('gamma'));
  assert(!aliceSection.includes('beta'));
  assert(bobSection.includes('beta'));
  assert(!bobSection.includes('alpha') && !bobSection.includes('gamma'));

  // header and rows
  assert(aliceSection.includes('| Requirement | Test ID | Status | Duration (s) | Owner | Evidence |'));
  assert(
    aliceSection.includes(
      '| REQ-123 | alpha | Passed | 0.000 | alice | \\[link\\](http://example.com/alpha.log) |'
    )
  );
  assert(
    aliceSection.includes(
      '| REQ-789 | gamma | Passed | 0.000 | alice | \\[link\\](http://example.com/gamma.log) |'
    )
  );
  assert(
    bobSection.includes(
      '| REQ-456 | beta | Passed | 0.000 | bob | \\[link\\](http://example.com/beta.log) |'
    )
  );
});

test('logs a warning when no JUnit files are found', async () => {
  const env = { ...process.env, RUNNER_OS: 'Linux' };
  const tsxPath = path.join(rootDir, 'node_modules/.bin/tsx');
  const cwd = path.join(fixtureDir, 'no-artifacts');
  const { stderr } = await execFileP(tsxPath, [scriptFile], { cwd, env });
  assert.match(stderr, /No JUnit files found/);
});

test('detects downloaded artifacts path', async () => {
  const env = { ...process.env, RUNNER_OS: 'Linux' };
  const tsxPath = path.join(rootDir, 'node_modules/.bin/tsx');
  const cwd = path.join(fixtureDir, 'downloaded-only');
  const { stdout } = await execFileP(tsxPath, [scriptFile], { cwd, env });
  assert.match(stdout, /<details><summary>alice<\/summary>/);
});

test('uses latest artifact directory when multiple are present', async () => {
  const env = { ...process.env, RUNNER_OS: 'Linux' };
  const tsxPath = path.join(rootDir, 'node_modules/.bin/tsx');
  const cwd = path.join(fixtureDir, 'multiple-artifacts');
  const { stdout } = await execFileP(tsxPath, [scriptFile], { cwd, env });
  assert.match(stdout, /<details><summary>dave<\/summary>/);
  assert.doesNotMatch(stdout, /<details><summary>carol<\/summary>/);
});
