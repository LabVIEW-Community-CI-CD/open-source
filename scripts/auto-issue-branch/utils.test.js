import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildIssueBranchName } from './utils.js';

test('buildIssueBranchName formats branch name', () => {
  assert.equal(buildIssueBranchName(123), 'issue/123');
});

test('buildIssueBranchName rejects non-numeric input', () => {
  assert.throws(() => buildIssueBranchName('abc'), {
    name: 'TypeError'
  });
});
