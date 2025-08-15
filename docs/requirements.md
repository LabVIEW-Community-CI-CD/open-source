# Requirements

This project tracks high‑level requirements and maps each one to the Pester test
files that verify it. The authoritative mapping is stored in
[`requirements.json`](requirements.json); the table below provides a human‑readable
summary for quick reference.

| ID | Description | Tests |
|----|-------------|-------|
| REQ-001 | Dispatcher discovers available actions, describes them, and validates arguments. | `tests/pester/Dispatcher.Tests.ps1` |
| REQ-002 | Dispatcher dry‑run mode prints descriptions and warns on unknown arguments without executing actions. | `tests/pester/Dispatcher.DryRun.Tests.ps1` |
| REQ-003 | Actions correctly resolve and pass RelativePath arguments without warnings. | `tests/pester/RelativePath.Actions.Tests.ps1` |
| REQ-004 | Every action script exists at the expected path. | `tests/pester/ScriptPath.Tests.ps1` |
| REQ-005 | Dispatcher fails when RelativePath is missing or invalid. | `tests/pester/Dispatcher.InvalidPaths.Tests.ps1` |

Each test file is annotated with its corresponding requirement ID to maintain
traceability between requirements and test coverage.

