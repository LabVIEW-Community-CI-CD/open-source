#!/usr/bin/env ts-node
import { promises as fs } from 'fs';
import path from 'path';

/**
 * Load requirement mappings from a JSON file. Returns empty object when file
 * cannot be parsed or does not exist.
 */
export async function loadRequirementMapping(mappingPath: string): Promise<Record<string, string>> {
  try {
    const contents = await fs.readFile(mappingPath, 'utf8');
    return JSON.parse(contents) as Record<string, string>;
  } catch (err: any) {
    console.warn(`Unable to read requirement mapping file at ${mappingPath}: ${err.message}`);
    return {};
  }
}

/**
 * Find the requirement identifier for a given test name. Returns undefined if
 * the test name is not present in the mapping.
 */
export function findRequirementId(testName: string, mapping: Record<string, string>): string | undefined {
  for (const [id, name] of Object.entries(mapping)) {
    if (name === testName) {
      return id;
    }
  }
  return undefined;
}

async function main() {
  const mappingFile = process.env.REQ_MAPPING_FILE ?? 'requirements.json';
  const mapping = await loadRequirementMapping(path.resolve(mappingFile));

  const testName = process.argv[2];
  if (!testName) {
    console.log('No test name provided');
    return;
  }

  const req = findRequirementId(testName, mapping);
  if (req) {
    console.log(`${testName} maps to requirement ${req}`);
  } else {
    console.log(`No requirement mapping found for ${testName}`);
  }
}

// Only run main when executed directly (not when imported for tests)
if (process.argv[1] && process.argv[1].endsWith('generate-ci-summary.ts')) {
  main();
}
