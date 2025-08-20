#!/usr/bin/env tsx
import fs from 'fs/promises';
import path from 'path';
import { pathToFileURL } from 'url';
import { writeErrorSummary } from './error-handler.ts';

async function main() {
  const traceFile = process.env.TRACEABILITY_JSON ?? 'artifacts/linux/traceability.json';
  const outFile = process.env.BADGE_JSON ?? 'artifacts/linux/badge-summary.json';
  const raw = await fs.readFile(traceFile, 'utf8');
  const { totals } = JSON.parse(raw);
  const overall = totals.overall;
  const total = overall.passed + overall.failed + overall.skipped;
  const rate = overall.rate ?? (total === 0 ? 0 : Math.round((overall.passed / total) * 100));
  const color = rate === 100 ? 'green' : rate >= 80 ? 'yellow' : 'red';
  const badge = {
    schemaVersion: 1,
    label: 'requirements',
    message: `${overall.passed}/${total} (${rate}%)`,
    color,
  };
  await fs.mkdir(path.dirname(outFile), { recursive: true });
  await fs.writeFile(outFile, JSON.stringify(badge));
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  main().catch(async err => {
    await writeErrorSummary(err);
    process.exit(1);
  });
}
