# Requirements

This project tracks high‑level requirements and maps each one to the Pester test files that verify it. The authoritative mapping is stored in [`requirements.json`](../requirements.json); the table below provides a human‑readable summary for quick reference.

| ID | Description | Tests | Runner | Runner Type | Skip Dry Run |
|----|-------------|-------|--------|-------------|--------------|
| REQ-001 | Dispatcher discovers available actions, describes them, and validates arguments. | `tests/pester/Dispatcher.Tests.ps1` |  |  |  |
| REQ-002 | Dispatcher dry-run mode prints descriptions and warns on unknown arguments without executing actions. | `tests/pester/Dispatcher.DryRun.Tests.ps1` |  |  |  |
| REQ-003 | Actions correctly resolve and pass RelativePath arguments without warnings. | `tests/pester/RelativePath.Actions.Tests.ps1` |  |  |  |
| REQ-004 | Every action script exists at the expected path. | `tests/pester/ScriptPath.Tests.ps1` |  |  |  |
| REQ-005 | Dispatcher fails when RelativePath is missing or invalid. | `tests/pester/Dispatcher.InvalidPaths.Tests.ps1` |  |  |  |
| REQ-006 | Workflow checks out the LabVIEW icon editor repository and tests the composite action defined in apply-vipc/action.yml with minimum_supported_lv_version '2021', vip_lv_version '2021', supported_bitness '64', relative_path 'C:\actions-runner\_work\labview-icon-editor\labview-icon-editor', and vipc_path 'C:\actions-runner\_work\labview-icon-editor\labview-icon-editor\.github\actions\apply-vipc\runner_dependencies.vipc' on a self-hosted Windows runner labeled icon-editor-windows with dry_run true. | `tests/pester/ApplyVipc.SelfHosted.DryRunTrue.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-007 | Workflow checks out the LabVIEW icon editor repository and tests the composite action defined in apply-vipc/action.yml with minimum_supported_lv_version '2021', vip_lv_version '2021', supported_bitness '64', relative_path 'C:\actions-runner\_work\labview-icon-editor\labview-icon-editor', and vipc_path 'C:\actions-runner\_work\labview-icon-editor\labview-icon-editor\.github\actions\apply-vipc\runner_dependencies.vipc' on a self-hosted Windows runner labeled icon-editor-windows with dry_run false. | `tests/pester/ApplyVipc.SelfHosted.DryRunFalse.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-008 | Workflow tests the composite action defined in add-token-to-labview/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/AddTokenToLabview.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-009 | Workflow tests the composite action defined in build/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/Build.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-010 | Workflow tests the composite action defined in build-lvlibp/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/BuildLvlibp.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-011 | Workflow tests the composite action defined in build-vi-package/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/BuildViPackage.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-012 | Workflow clones an external repository and operates on it without modification using the composite action defined in close-labview/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/CloseLabview.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-013 | Workflow tests the composite action defined in generate-release-notes/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/GenerateReleaseNotes.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-014 | Workflow tests the composite action defined in missing-in-project/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/MissingInProject.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-015 | Workflow tests the composite action defined in modify-vipb-display-info/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/ModifyVipbDisplayInfo.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-016 | Workflow tests the composite action defined in prepare-labview-source/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/PrepareLabviewSource.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-017 | Workflow tests the composite action defined in rename-file/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/RenameFile.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-018 | Workflow tests the composite action defined in restore-setup-lv-source/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/RestoreSetupLvSource.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-019 | Workflow tests the composite action defined in revert-development-mode/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/RevertDevelopmentMode.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-020 | Workflow tests the composite action defined in run-unit-tests/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/RunUnitTests.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-021 | Workflow tests the composite action defined in set-development-mode/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/SetDevelopmentMode.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
| REQ-022 | Workflow tests the composite action defined in setup-mkdocs/action.yml on a self-hosted Windows runner labeled icon-editor-windows. | `tests/pester/SetupMkdocs.SelfHosted.Workflow.ps1` | icon-editor-windows | integration | true |
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

Each test file is annotated with its corresponding requirement ID to maintain traceability between requirements and test coverage.

During CI runs, `scripts/generate-ci-summary.ts` writes requirement artifacts to an OS‑specific directory under `artifacts/`, such as `artifacts/windows/traceability.md` or `artifacts/linux/traceability.md`, using the `RUNNER_OS` environment variable.

Each directory also includes a `summary.md` file with per‑OS totals. A typical summary might look like this:

| OS | Passed | Failed | Skipped | Duration (s) | Pass Rate (%) |
| --- | --- | --- | --- | --- | --- |
| overall | 10 | 0 | 2 | 12.34 | 100.00 |
| windows | 5 | 0 | 1 | 6.17 | 100.00 |
| linux | 5 | 0 | 1 | 6.17 | 100.00 |
