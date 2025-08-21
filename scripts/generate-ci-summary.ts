#!/usr/bin/env tsx
import fs from 'fs/promises';
import { constants as fsConstants } from 'fs';
import path from 'path';
import os from 'os';
import { pathToFileURL } from 'url';
import { glob } from 'glob';
import AdmZip from 'adm-zip';
import { writeErrorSummary } from './error-handler.ts';
import { execSync } from 'child_process';
import {
  buildSummary,
  summaryToMarkdown,
  requirementsSummaryToMarkdown,
  requirementTestsToMarkdown,
  groupToMarkdown,
  computeStatusCounts,
  TestCase,
  RequirementGroup,
} from './summary/index.ts';
import { generateActionDocs } from './summary/generate-action-docs.ts';
import { collectTestCases } from './summary/tests.ts';
import { loadRequirements, mapToRequirements, redact } from './summary/requirements.ts';

async function main() {
  const hasRunnerMeta = Boolean(
    process.env.RUNNER_LABEL ||
      process.env.RUNNER_TYPE ||
      process.env.SKIP_DRY_RUN,
  );
  if (!hasRunnerMeta) {
    console.error(
      'At least one of RUNNER_LABEL, RUNNER_TYPE, or SKIP_DRY_RUN must be set',
    );
    process.exit(1);
  }
  const mappingFiles = (process.env.REQ_MAPPING_FILE || 'requirements.json')
    .split(',')
    .map((s) => s.trim())
    .filter(Boolean);
  const dispatcherRegistryFile = process.env.DISPATCHER_REGISTRY || 'dispatchers.json';
  const evidenceDir = process.env.EVIDENCE_DIR || 'test-screenshots';
  const osType = (process.env.RUNNER_OS ?? 'linux').toLowerCase();

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
    const single = process.env.TEST_RESULTS_GLOB || 'artifacts/**/*junit*.xml';
    junitFiles = await glob(single, { nodir: true });
  }

  let extractedDir: string | null = null;
  const expanded: string[] = [];
  for (const f of junitFiles) {
    if (f.toLowerCase().endsWith('.zip')) {
      if (!extractedDir) {
        extractedDir = await fs.mkdtemp(path.join(os.tmpdir(), 'junit-'));
      }
      try {
        const zip = new AdmZip(f);
        for (const entry of zip.getEntries()) {
          if (!entry.isDirectory && entry.entryName.toLowerCase().endsWith('.xml')) {
            const dest = path.join(extractedDir, path.basename(entry.entryName));
            await fs.writeFile(dest, entry.getData());
            expanded.push(dest);
          }
        }
      } catch (err) {
        console.warn(`Failed to extract JUnit archive ${f}:`, err);
      }
    } else {
      expanded.push(f);
    }
  }
  junitFiles = expanded;
  const requireResults = !!process.env.REQUIRE_TEST_RESULTS;
  let tests: TestCase[] = [];
  try {
    if (junitFiles.length === 0) {
      const msg = 'No JUnit files found';
      if (requireResults) {
        throw new Error(msg);
      }
      console.warn(`${msg}; writing empty summary.`);
    } else {
      tests = await collectTestCases(junitFiles, evidenceDir, osType);
    }
  } finally {
    if (extractedDir) await fs.rm(extractedDir, { recursive: true, force: true });
  }
  const { map, meta } = await loadRequirements(mappingFiles);
  const groups = mapToRequirements(tests, map, meta);
  const allUnmapped = groups.every(g => g.id === 'Unmapped');
  if (allUnmapped) {
    const msg = 'All tests are unmapped; verify requirements mapping.';
    if (process.env.REQUIRE_REQUIREMENTS_MAPPING) {
      throw new Error(msg);
    }
    console.warn(msg);
  }
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

  const gitSha =
    process.env.GITHUB_SHA || execSync('git rev-parse HEAD', { encoding: 'utf8' }).trim();
  const reqStatus: Record<string, string> = {};
  for (const g of groups) {
    if (g.id === 'Unmapped') continue;
    const { failed, total } = computeStatusCounts(g.tests);
    reqStatus[g.id] = failed > 0 || total === 0 ? 'FAIL' : 'PASS';
  }
  const evidence = {
    pipeline: process.env.PIPELINE_NAME || 'Unknown',
    git_sha: gitSha,
    req_status: reqStatus,
  };
  const evidenceStr = JSON.stringify(evidence);
  await fs.writeFile('ci_evidence.txt', evidenceStr);
  console.log(`CI_EVIDENCE=${evidenceStr}`);

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
