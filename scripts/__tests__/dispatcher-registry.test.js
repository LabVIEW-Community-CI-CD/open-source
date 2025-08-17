import fs from 'fs';
import { test } from 'node:test';
import assert from 'node:assert';

test('All dispatchers have parameters', () => {
  const registry = JSON.parse(
    fs.readFileSync(new URL('../../dispatchers.json', import.meta.url), 'utf8')
  );
  for (const [name, info] of Object.entries(registry)) {
    assert.ok(
      Object.keys(info.parameters).length > 0,
      `${name} has empty parameters`
    );
  }
});
