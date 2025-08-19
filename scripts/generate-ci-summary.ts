#!/usr/bin/env tsx
import fs from 'fs/promises';
import { constants as fsConstants } from 'fs';
import path from 'path';
import { pathToFileURL } from 'url';
import { glob } from 'glob';
import { writeErrorSummary } from './error-handler.ts';
import {
  buildSummary,
  summaryToMarkdown,
  requirementsSummaryToMarkdown,
  requirementTestsToMarkdown,
  groupToMarkdown,
  TestCase,
  RequirementGroup,
} from './summary/index.ts';
import { generateActionDocs } from './summary/generate-action-docs.ts';
import { collectTestCases } from './summary/tests.ts';
import { loadRequirements, mapToRequirements, redact } from './summary/requirements.ts';

async function main() {
  const mappingFile = process.env.REQ_MAPPING_FILE || 'requirements.json';
  const dispatcherRegistryFile = process.env.DISPATCHER_REGISTRY || 'dispatchers.json';
  const evidenceDir = process.env.EVIDENCE_DIR || 'test-screenshots';
  const osType = (process.env.RUNNER_OS ?? 'unknown').toLowerCase();

  let junitFiles: string[] = [];
  const plural = process.env.TEST_RESULTS_GLOBS;
  if (plural) {
    const patterns = plural.split(/\s+/).filter(Boolean);
    const found = new Set<string>();
    for (const p of patterns) {
      const matches = await glob(p, { nodir: true });
      for (const f of matches) found.add(f);
    }
    junitFiles = Array.from(found);
  } else {
    const single = process.env.TEST_RESULTS_GLOB || '**/*junit*.xml';
    junitFiles = await glob(single, { nodir: true });
  }
  let tests: TestCase[] = [];
  if (junitFiles.length === 0) {
    console.warn('No JUnit files found; writing empty summary.');
  } else {
    tests = await collectTestCases(junitFiles, evidenceDir, osType);
  }
  const { map, meta } = await loadRequirements(mappingFile);
  const groups = mapToRequirements(tests, map, meta);
  const totals = buildSummary(groups);

  const outDir = path.join('artifacts', osType);
  await fs.mkdir(outDir, { recursive: true });

  const matrixMd = groupToMarkdown(groups);
  const summaryMd = summaryToMarkdown(totals);
  const requirementsMd = requirementsSummaryToMarkdown(groups);
  const requirementsTestsMd = requirementTestsToMarkdown(groups);

  const wrapperFiles = await glob('*/action.yml', { nodir: true });
  const wrapperDirs = wrapperFiles.map(f => path.dirname(f)).sort();
  console.log('Discovered wrapper directories:', wrapperDirs.join(', '));
  const { docs, markdown } = await generateActionDocs(dispatcherRegistryFile, wrapperDirs);

  await fs.writeFile(path.join(outDir, 'traceability.json'), JSON.stringify({ requirements: groups, totals }, null, 2));
  await fs.writeFile(path.join(outDir, 'traceability.md'), redact(`### Test Traceability Matrix\n\n${matrixMd}`));
  const combinedSummary = `${summaryMd}\n\n${requirementsMd}\n\n_For detailed per-test information, see [traceability.md](traceability.md)._`;
  await fs.writeFile(path.join(outDir, 'summary.md'), redact(combinedSummary));
  const reqSummary = `${requirementsMd}\n\n${requirementsTestsMd}`;
  await fs.writeFile(path.join(outDir, 'requirements-summary.md'), redact(reqSummary));
  await fs.writeFile(path.join(outDir, 'action-docs.json'), JSON.stringify(docs, null, 2));
  await fs.writeFile(path.join(outDir, 'action-docs.md'), redact(markdown));

  const partitions: Record<string, RequirementGroup[]> = {};
  for (const g of groups) {
    const type = g.runner_type ?? 'standard';
    if (!partitions[type]) partitions[type] = [];
    partitions[type].push(g);
  }

  for (const [type, list] of Object.entries(partitions)) {
    const partTotals = buildSummary(list);
    const partSummary = summaryToMarkdown(partTotals);
    await fs.writeFile(
      path.join(outDir, `summary-${type}.md`),
      redact(
        `${partSummary}\n\n_For detailed per-test information, see [traceability-${type}.md](traceability-${type}.md)._`,
      ),
    );
    await fs.writeFile(
      path.join(outDir, `traceability-${type}.md`),
      redact(`### Test Traceability Matrix\n\n${groupToMarkdown(list)}`),
    );
  }

  try {
    await fs.access(evidenceDir, fsConstants.R_OK);
    await fs.cp(evidenceDir, path.join(outDir, 'evidence'), { recursive: true });
  } catch {
    // ignore missing evidence
  }
}

if (import.meta.url === pathToFileURL(process.argv[1] ?? '').href) {
  main().catch(async (err: unknown) => {
    await writeErrorSummary(err);
    process.exit(1);
  });
}
