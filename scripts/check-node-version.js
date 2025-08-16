import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));
const pkg = JSON.parse(readFileSync(resolve(__dirname, '../package.json'), 'utf8'));
const required = pkg.engines?.node ?? '>=0';
const current = process.versions.node;

const parseMajor = (v) => parseInt(v.replace(/^>=?/, '').split('.')[0], 10);
const requiredMajor = parseMajor(required);
const currentMajor = parseInt(current.split('.')[0], 10);

if (Number.isNaN(requiredMajor)) {
  console.error(`Unsupported Node version range: ${required}`);
  process.exit(1);
}

if (currentMajor < requiredMajor) {
  console.error(`Node.js ${required} required, but ${current} found.`);
  process.exit(1);
}

console.log(`Node.js version ${current} satisfies ${required}.`);
