import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'fs/promises';
import { fileURLToPath } from 'url';
import path from 'path';
import { loadRequirementMapping, findRequirementId, parseJUnitFile, renderActionDoc } from './generate-ci-summary.ts';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const mappingPath = path.resolve(__dirname, '../requirements.json');

test('loadRequirementMapping reads file and findRequirementId works', async () => {
  const mapping = await loadRequirementMapping(mappingPath);
  assert.equal(findRequirementId('Dispatcher.Tests', mapping), 'REQ-001');
  assert.equal(findRequirementId('Unknown.Tests', mapping), undefined);
});

test('parseJUnitFile parses simple JUnit XML', async () => {
  const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<testsuite name="Sample" tests="3" failures="1">\n  <testcase name="a"/>\n  <testcase name="b"><failure/></testcase>\n  <testcase name="c"/>\n</testsuite>`;
  const junitPath = path.join(__dirname, 'sample-junit.xml');
  await fs.writeFile(junitPath, xml);
  const suites = await parseJUnitFile(junitPath);
  await fs.unlink(junitPath);
  assert.equal(suites.length, 1);
  assert.deepEqual(suites[0], { name: 'Sample', tests: 3, failures: 1, passed: 2 });
});

test('renderActionDoc fills template placeholders', async () => {
  const templatePath = path.resolve(__dirname, '../doc-templates/action-doc-template.md');
  const template = await fs.readFile(templatePath, 'utf8');
  const info = {
    name: 'demo-action',
    synopsis: 'Demo synopsis',
    description: '',
    parameters: [
      { name: 'Req', type: 'string', required: true, description: 'required param' },
      { name: 'Opt', type: 'number', required: false, description: 'optional param' },
    ],
  };
  const md = renderActionDoc(template, info);
  assert.ok(md.includes('demo-action'));
  assert.ok(md.includes('**Req** (`string`): required param'));
  assert.ok(md.includes('**Opt** (`number`): optional param'));
  assert.ok(md.includes('pwsh -File actions/Invoke-OSAction.ps1 -ActionName demo-action'));
  assert.ok(md.includes('action_name: demo-action'));
});
