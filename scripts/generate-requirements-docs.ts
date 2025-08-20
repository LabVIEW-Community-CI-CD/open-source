import fs from 'fs/promises';
import path from 'path';

interface RunnerInfo {
  runner_label?: string;
  runner_type?: string;
  skip_dry_run?: boolean;
}

interface Requirement {
  id: string;
  description: string;
  tests?: string[];
  runner?: string;
  skip_dry_run?: boolean;
}

async function main() {
  const reqFile = process.env.REQ_MAPPING_FILE || 'requirements.json';
  const raw = JSON.parse(await fs.readFile(reqFile, 'utf8'));
  const runners: Record<string, RunnerInfo> = raw.runners ?? {};
  const requirements: Requirement[] = raw.requirements ?? [];

  const relativeLink = path.join('..', reqFile).replace(/\\/g, '/');
  const header = `# Requirements\n\nThis project tracks high\u2011level requirements and maps each one to the Pester test files that verify it. The authoritative mapping is stored in [\`${reqFile}\`](${relativeLink}); the table below provides a human\u2011readable summary for quick reference.\n\nIf every test maps to \`Unmapped\`, the \`scripts/generate-ci-summary.ts\` script logs a warning. Set \`REQUIRE_REQUIREMENTS_MAPPING\` in the environment to treat this situation as an error.\n\nRunner Type indicates whether a requirement runs on a standard GitHub-hosted image or an integration runner with preinstalled tooling. See [runner-types](runner-types.md) for guidance on choosing between them.\n\n| ID | Description | Tests | Runner | Runner Type | Skip Dry Run |\n|----|-------------|-------|--------|-------------|--------------|\n`;

  const escapeCell = (text: string) =>
    text.replace(/\|/g, '\\|').replace(/</g, '&lt;').replace(/>/g, '&gt;');

  const rows = requirements
    .map((req) => {
      const tests = (req.tests ?? [])
        .map((t) => (t.includes('/') ? t : `tests/pester/${t}.ps1`))
        .map((t) => `\`${t}\``)
        .join(', ');

      let runnerLabel = '';
      let runnerType = '';
      let skipDryRun: string = '';
      if (req.runner) {
        const info = runners[req.runner] || {};
        runnerLabel = info.runner_label ?? '';
        runnerType = info.runner_type ?? '';
        const skip = req.skip_dry_run ?? info.skip_dry_run;
        if (skip !== undefined) skipDryRun = String(skip);
      } else if (req.skip_dry_run !== undefined) {
        skipDryRun = String(req.skip_dry_run);
      }

      const desc = escapeCell(req.description.replace(/\s+/g, ' ').trim());
      return `| ${req.id} | ${desc} | ${tests} | ${runnerLabel} | ${runnerType} | ${skipDryRun} |`;
    })
    .join('\n');

  const footer = `\n\nEach test file is annotated with its corresponding requirement ID to maintain traceability between requirements and test coverage.\n\nDuring CI runs, \`scripts/generate-ci-summary.ts\` writes requirement artifacts to an OS\u2011specific directory under \`artifacts/\`, such as \`artifacts/windows/traceability.md\` or \`artifacts/linux/traceability.md\`, using the \`RUNNER_OS\` environment variable.\n\nEach directory also includes a \`summary.md\` file with per\u2011OS totals. A typical summary might look like this:\n\n| OS | Passed | Failed | Skipped | Duration (s) | Pass Rate (%) |\n| --- | --- | --- | --- | --- | --- |\n| overall | 10 | 0 | 2 | 12.34 | 100.00 |\n| windows | 5 | 0 | 1 | 6.17 | 100.00 |\n| linux | 5 | 0 | 1 | 6.17 | 100.00 |\n`;

  const docFile = process.env.REQ_DOC_FILE || path.join('docs', 'requirements.md');
  const content = header + rows + footer;
  await fs.writeFile(docFile, content);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
