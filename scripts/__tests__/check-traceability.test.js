import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { execFile } from 'node:child_process';
import { promisify } from 'node:util';

const execFileP = promisify(execFile);
const script = path.resolve('scripts/check-traceability.ts');
const tsx = path.resolve('node_modules/.bin/tsx');

async function initRepo(dir, msg) {
  await execFileP('git', ['init', '-b', 'main'], { cwd: dir });
  await fs.writeFile(path.join(dir, 'file.txt'), 'a');
  await execFileP('git', ['add', '.'], { cwd: dir });
  await execFileP('git', ['commit', '-m', msg], { cwd: dir });
}

test('fails when requirement lacks test coverage', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'trace-'));
  const req = { requirements: [{ id: 'REQ-1', tests: ['t1'] }] };
  await fs.writeFile(path.join(dir, 'requirements.json'), JSON.stringify(req));
  const trace = { requirements: [{ id: 'REQ-1', tests: [] }] };
  await fs.writeFile(path.join(dir, 'trace.json'), JSON.stringify(trace));
  await initRepo(dir, 'initial REQ-1');
  await assert.rejects(
    execFileP(tsx, [script], {
      cwd: dir,
      env: { ...process.env, REQ_MAPPING_FILE: 'requirements.json', TRACEABILITY_FILE: 'trace.json' },
    }),
    /No tests executed/
  );
  await fs.rm(dir, { recursive: true, force: true });
});

test('fails when commit lacks requirement reference', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'trace-'));
  const req = { requirements: [{ id: 'REQ-1', tests: ['t1'] }] };
  await fs.writeFile(path.join(dir, 'requirements.json'), JSON.stringify(req));
  const trace = { requirements: [{ id: 'REQ-1', tests: [{ id: 't1', status: 'Passed' }] }] };
  await fs.writeFile(path.join(dir, 'trace.json'), JSON.stringify(trace));
  await initRepo(dir, 'initial commit');
  await assert.rejects(
    execFileP(tsx, [script], {
      cwd: dir,
      env: { ...process.env, REQ_MAPPING_FILE: 'requirements.json', TRACEABILITY_FILE: 'trace.json', PR_BODY: '' },
    }),
    /No requirement references/
  );
  await fs.rm(dir, { recursive: true, force: true });
});

test('passes with coverage and requirement reference', async () => {
  const dir = await fs.mkdtemp(path.join(os.tmpdir(), 'trace-'));
  const req = { requirements: [{ id: 'REQ-1', tests: ['t1'] }] };
  await fs.writeFile(path.join(dir, 'requirements.json'), JSON.stringify(req));
  const trace = { requirements: [{ id: 'REQ-1', tests: [{ id: 't1', status: 'Passed' }] }] };
  await fs.writeFile(path.join(dir, 'trace.json'), JSON.stringify(trace));
  await initRepo(dir, 'initial REQ-1');
  await execFileP(tsx, [script], {
    cwd: dir,
    env: { ...process.env, REQ_MAPPING_FILE: 'requirements.json', TRACEABILITY_FILE: 'trace.json' },
  });
  await fs.rm(dir, { recursive: true, force: true });
});
