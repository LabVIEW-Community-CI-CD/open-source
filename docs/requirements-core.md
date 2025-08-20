# Requirements

This project tracks high‑level requirements and maps each one to the Pester test files that verify it. The authoritative mapping is stored in [`requirements-core.json`](../requirements-core.json); the table below provides a human‑readable summary for quick reference.

If every test maps to `Unmapped`, the `scripts/generate-ci-summary.ts` script logs a warning. Set `REQUIRE_REQUIREMENTS_MAPPING` in the environment to treat this situation as an error.

Runner Type indicates whether a requirement runs on a standard GitHub-hosted image or an integration runner with preinstalled tooling. See [runner-types](runner-types.md) for guidance on choosing between them.

| ID | Description | Tests | Runner | Runner Type | Skip Dry Run |
|----|-------------|-------|--------|-------------|--------------|
| REQ-001 | Dispatcher discovers available actions, describes them, and validates arguments. | `tests/pester/Dispatcher.Tests.ps1` |  |  |  |
| REQ-002 | Dispatcher dry-run mode prints descriptions and warns on unknown arguments without executing actions. | `tests/pester/Dispatcher.DryRun.Tests.ps1` |  |  |  |
| REQ-003 | Actions resolve RelativePath arguments using the action's WorkingDirectory as the base path and pass them without warnings, including when RelativePath is '.' and the WorkingDirectory targets subdirectories. | `tests/pester/RelativePath.Actions.Tests.ps1` |  |  |  |
| REQ-004 | Every action script exists at the expected path. | `tests/pester/ScriptPath.Tests.ps1` |  |  |  |
| REQ-005 | Dispatcher fails when RelativePath is missing or invalid after resolving it relative to the specified WorkingDirectory. | `tests/pester/Dispatcher.InvalidPaths.Tests.ps1` |  |  |  |
| REQ-006 | Workflow tests the composite action defined in apply-vipc/action.yml with minimum_supported_lv_version '2021', vip_lv_version '2021', supported_bitness '64', relative_path '.', and vipc_path 'scripts/apply-vipc/runner_dependencies.vipc' on the GitHub-hosted Ubuntu runner labeled ubuntu-latest with dry_run true. | `tests/pester/ApplyVipc.DryRunTrue.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-008 | Workflow tests the composite action defined in add-token-to-labview/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/AddTokenToLabview.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-009 | Workflow tests the composite action defined in build/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/Build.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-010 | Workflow tests the composite action defined in build-lvlibp/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/BuildLvlibp.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-011 | Workflow tests the composite action defined in build-vi-package/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/BuildViPackage.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-012 | Workflow clones an external repository and operates on it without modification using the composite action defined in close-labview/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/CloseLabview.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-013 | Workflow tests the composite action defined in generate-release-notes/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/GenerateReleaseNotes.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-014 | Workflow tests the composite action defined in missing-in-project/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/MissingInProject.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-015 | Workflow tests the composite action defined in modify-vipb-display-info/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/ModifyVipbDisplayInfo.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-016 | Workflow tests the composite action defined in prepare-labview-source/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/PrepareLabviewSource.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-017 | Workflow tests the composite action defined in rename-file/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/RenameFile.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-018 | Workflow tests the composite action defined in restore-setup-lv-source/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/RestoreSetupLvSource.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-019 | Workflow tests the composite action defined in revert-development-mode/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/RevertDevelopmentMode.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-020 | Workflow tests the composite action defined in run-unit-tests/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/RunUnitTests.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-021 | Workflow tests the composite action defined in set-development-mode/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/SetDevelopmentMode.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-022 | Workflow tests the composite action defined in setup-mkdocs/action.yml on the GitHub-hosted Ubuntu runner labeled ubuntu-latest. | `tests/pester/SetupMkdocs.Workflow.ps1` | ubuntu-latest | integration | false |
| REQ-023 | Parser ingests JUnit XML artifacts starting at the testsuites root and iterating through nested suites and testcases. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-024 | Top-level testsuites attributes name, tests, errors, failures, disabled, and time are captured for summary reporting. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-025 | Each testsuite records attributes including name, tests, errors, failures, hostname, id, skipped, disabled, package, and time. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-026 | Suite properties are extracted as name/value pairs for environment details. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-027 | Testcase attributes name, status, classname, assertions, time, and any skip message are preserved. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-028 | Requirement identifiers embedded in testcase names are detected and associated with the test. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-029 | Test results are aggregated by requirement and by suite to count passed, failed, and skipped cases. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-030 | Traceability matrix links requirement IDs to testcases with status, execution time, host properties, and skipped reasons. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-031 | Parsing logic validates presence of required fields and reports missing or malformed data. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-032 | Parser tolerates and retains unknown attributes for future extensibility. | `scripts/__tests__/junit-parser.test.js` |  |  |  |
| REQ-033 | Tests ending with SelfHosted.Workflow.Tests.ps1 execute only in dry run mode unless the workflow targets a self-hosted Windows runner labeled self-hosted-windows-lv. | `tests/pester/SelfHosted.Workflow.Tests.ps1` |  |  |  |

Each test file is annotated with its corresponding requirement ID to maintain traceability between requirements and test coverage.

During CI runs, `scripts/generate-ci-summary.ts` writes requirement artifacts to an OS‑specific directory under `artifacts/`, such as `artifacts/windows/traceability.md` or `artifacts/linux/traceability.md`, using the `RUNNER_OS` environment variable.

Each directory also includes a `summary.md` file with per‑OS totals. A typical summary might look like this:

| OS | Passed | Failed | Skipped | Duration (s) | Pass Rate (%) |
| --- | --- | --- | --- | --- | --- |
| overall | 10 | 0 | 2 | 12.34 | 100.00 |
| windows | 5 | 0 | 1 | 6.17 | 100.00 |
| linux | 5 | 0 | 1 | 6.17 | 100.00 |
