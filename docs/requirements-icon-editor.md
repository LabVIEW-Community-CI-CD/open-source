# Requirements

This project tracks high‑level requirements and maps each one to the Pester test files that verify it. The authoritative mapping is stored in [`requirements-icon-editor.json`](../requirements-icon-editor.json); the table below provides a human‑readable summary for quick reference.

If every test maps to `Unmapped`, the `scripts/generate-ci-summary.ts` script logs a warning. Set `REQUIRE_REQUIREMENTS_MAPPING` in the environment to treat this situation as an error.

Runner Type indicates whether a requirement runs on a standard GitHub-hosted image or an integration runner with preinstalled tooling. See [runner-types](runner-types.md) for guidance on choosing between them.

| ID | Description | Tests | Runner | Runner Type | Skip Dry Run |
|----|-------------|-------|--------|-------------|--------------|
| REQIE-001 | Dispatcher dry-runs add-token-to-labview with expected arguments. | `tests/pester/BuildProfile1.IconEditor.AddTokenToLabview.Dispatcher.Tests.ps1` | self-hosted-windows-lv | integration | false |
| REQIE-002 | Dispatcher dry-runs apply-vipc with expected arguments including VIP_LVVersion and VIPCPath. | `tests/pester/BuildProfile1.IconEditor.ApplyVipc.Dispatcher.Tests.ps1` | self-hosted-windows-lv | integration | false |
| REQIE-008 | Dispatcher dry-runs build-vi-package with expected metadata and paths. | `tests/pester/BuildProfile1.IconEditor.BuildViPackage.Dispatcher.Tests.ps1` | self-hosted-windows-lv | integration | false |
| REQIE-010 | Dispatcher dry-runs close-labview with expected arguments. | `tests/pester/BuildProfile1.IconEditor.CloseLabview.Dispatcher.Tests.ps1` | self-hosted-windows-lv | integration | false |

Each test file is annotated with its corresponding requirement ID to maintain traceability between requirements and test coverage.

During CI runs, `scripts/generate-ci-summary.ts` writes requirement artifacts to an OS‑specific directory under `artifacts/`, such as `artifacts/windows/traceability.md` or `artifacts/linux/traceability.md`, using the `RUNNER_OS` environment variable.

Each directory also includes a `summary.md` file with per‑OS totals. A typical summary might look like this:

| OS | Passed | Failed | Skipped | Duration (s) | Pass Rate (%) |
| --- | --- | --- | --- | --- | --- |
| overall | 10 | 0 | 2 | 12.34 | 100.00 |
| windows | 5 | 0 | 1 | 6.17 | 100.00 |
| linux | 5 | 0 | 1 | 6.17 | 100.00 |
