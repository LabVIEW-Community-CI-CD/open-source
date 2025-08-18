import test from 'node:test';
import assert from 'node:assert/strict';
import { formatError } from '../error-handler.ts';

test('formatError handles real Error objects', () => {
  const err = new Error('boom');
  const result = formatError(err);
  assert.strictEqual(result, err.stack);
});

test('formatError handles plain objects', () => {
  const obj = { message: 'oops' };
  const result = formatError(obj);
  assert.strictEqual(result, JSON.stringify(obj));
});

test('formatError handles primitives', () => {
  assert.strictEqual(formatError(42), '42');
});

test('formatError handles unstringifiable values', () => {
  const obj = {};
  obj.self = obj;
  obj.toString = () => { throw new Error('fail'); };
  const result = formatError(obj);
  assert.strictEqual(result, 'Unknown error');
});
