import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs/promises';

const fileUrl = new URL('../generate-ci-summary.ts', import.meta.url);

test('generate-ci-summary features', async () => {
  const content = await fs.readFile(fileUrl, 'utf8');
  assert.match(content, /TEST_RESULTS_GLOBS/);
  assert.match(content, /<redacted>/);
  assert.match(content, /<details><summary>/);
});
