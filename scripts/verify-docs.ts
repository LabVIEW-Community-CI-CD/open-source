import { promises as fs } from 'fs';
import path from 'path';
import yaml from 'js-yaml';
import { glob } from 'glob';

interface DocEntry {
  description: string;
  default?: string;
}

async function parseDoc(md: string): Promise<Record<string, DocEntry>> {
  const lines = md.split(/\r?\n/);
  const start = lines.findIndex((l) => l.trim().startsWith('| Input |'));
  if (start === -1) return {};
  const headers = lines[start].split('|').slice(1, -1).map((h) => h.trim().toLowerCase());
  const colIndex: Record<string, number> = {};
  headers.forEach((h, i) => (colIndex[h] = i));
  const table: Record<string, DocEntry> = {};
  for (let i = start + 2; i < lines.length; i++) {
    const line = lines[i];
    if (!line.trim().startsWith('|')) break;
    const cols = line.split('|').slice(1, -1).map((c) => c.trim().replace(/^`|`$/g, ''));
    const input = cols[colIndex['input']];
    const description = cols[colIndex['description']];
    const defaultVal = colIndex['default'] !== undefined ? cols[colIndex['default']] : undefined;
    table[input] = { description, default: defaultVal };
  }
  return table;
}

async function exists(p: string) {
  try {
    await fs.access(p);
    return true;
  } catch {
    return false;
  }
}

async function main() {
  const files = await glob('*/action.yml');
  let errors = false;
  for (const file of files) {
    const action = path.dirname(file);
    const docPath = path.join('docs', 'actions', `${action}.md`);
    if (!(await exists(docPath))) {
      console.error(`Missing documentation for action '${action}'`);
      errors = true;
      continue;
    }
    const actionYaml = yaml.load(await fs.readFile(file, 'utf8')) as any;
    const inputs = actionYaml.inputs ?? {};
    const docTable = await parseDoc(await fs.readFile(docPath, 'utf8'));
    for (const [name, props] of Object.entries<any>(inputs)) {
      if (!(name in docTable)) {
        console.error(`${action}: input '${name}' missing from docs`);
        errors = true;
        continue;
      }
      const doc = docTable[name];
      const desc = (props.description ?? '').trim();
      if (doc.description.trim() !== desc) {
        console.error(`${action}: description mismatch for '${name}'`);
        errors = true;
      }
      const def = props.default;
      if (def !== undefined) {
        if (doc.default === undefined || doc.default !== String(def)) {
          console.error(`${action}: default mismatch for '${name}'`);
          errors = true;
        }
      } else if (doc.default !== undefined && doc.default !== '') {
        console.error(`${action}: docs specify default for '${name}' but action.yml has none`);
        errors = true;
      }
    }
    for (const name of Object.keys(docTable)) {
      if (!(name in inputs)) {
        console.error(`${action}: docs include extra input '${name}'`);
        errors = true;
      }
    }
  }
  if (errors) process.exit(1);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
