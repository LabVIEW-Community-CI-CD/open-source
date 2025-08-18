import fs from 'fs';
import { test } from 'node:test';
import assert from 'node:assert';

test('Dispatchers and parameters include descriptions', () => {
  const registry = JSON.parse(
    fs.readFileSync(new URL('../../dispatchers.json', import.meta.url), 'utf8')
  );
  for (const [name, info] of Object.entries(registry)) {
    assert.ok(info.description, `${name} is missing a description`);
    assert.ok(
      Object.keys(info.parameters).length > 0,
      `${name} has empty parameters`
    );
    for (const [paramName, paramInfo] of Object.entries(info.parameters)) {
      assert.ok(
        paramInfo.description,
        `${name}.${paramName} is missing a description`
      );
    }
  }
});
