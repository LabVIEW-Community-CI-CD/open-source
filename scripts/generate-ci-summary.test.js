import test from 'node:test';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'url';
import path from 'path';
import { loadRequirementMapping, findRequirementId } from './generate-ci-summary.ts';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const mappingPath = path.resolve(__dirname, '../requirements.json');

test('loadRequirementMapping reads file and findRequirementId works', async () => {
  const mapping = await loadRequirementMapping(mappingPath);
  assert.equal(findRequirementId('Dispatcher.Tests', mapping), 'REQ-001');
  assert.equal(findRequirementId('Unknown.Tests', mapping), undefined);
});
