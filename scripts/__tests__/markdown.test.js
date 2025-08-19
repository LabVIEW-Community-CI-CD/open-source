import test from 'node:test';
import assert from 'node:assert/strict';
import { escapeMarkdown } from '../utils/markdown.ts';

test('escapeMarkdown escapes special characters', () => {
  const input = '`*_[]|';
  const expected = '\\`\\*\\_\\[\\]\\|';
  assert.strictEqual(escapeMarkdown(input), expected);
});

test('escapeMarkdown leaves plain text untouched', () => {
  const input = 'plain text';
  assert.strictEqual(escapeMarkdown(input), input);
});
