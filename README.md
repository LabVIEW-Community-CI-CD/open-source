# LabVIEW Community CI/CD — Unified Dispatcher

A single, stable entrypoint for all repo PowerShell tasks. Instead of calling individual scripts, invoke:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName <name> -ArgsJson <json> `
  [-WorkingDirectory <path>] [-LogLevel ERROR|WARN|INFO|DEBUG] `
  [-DryRun] [-ListActions] [-Describe <name>]
```

This decouples workflows from script paths and parameter quirks, preserves each script’s exit codes, and adds discovery with -ListActions / -Describe. Decisions and acceptance criteria were captured in the research doc.

## Requirements

- PowerShell 7+ (pwsh)
- LabVIEW and g‑cli installed and on `PATH`
- Works on Windows and Linux when LabVIEW + g‑cli are present.
- If g-cli isn’t on `PATH`, pass a `gcliPath` in `args_json` to prepend it at runtime.
- Some leaf scripts may be Windows‑specific (e.g., VIPM/registry dependencies). The dispatcher itself is cross‑platform.

## Quick Start

List available actions:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ListActions
```

Describe parameters for one action:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -Describe build-lvlibp
```

Run an action (example: apply a VIPC) — `-DryRun` to preview:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName apply-vipc `
  -ArgsJson '{ "MinimumSupportedLVVersion":"2021","VIP_LVVersion":"2021","SupportedBitness":"64","RelativePath":".","VIPCPath":"MyLib.vipc" }' `
  -DryRun -LogLevel INFO
```

Run unit tests (works on Windows or Linux if LabVIEW + g‑cli are available):

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests `
  -ArgsJson '{ "MinimumSupportedLVVersion":"2021","SupportedBitness":"64","gcliPath":"/opt/gcli/bin" }'
```

## Using the Composite Action in Workflows

```yaml
jobs:
  build:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ./actions/abstract-action
        with:
          action_name: build-lvlibp
          args_json: >
            {
              "MinimumSupportedLVVersion": "2021",
              "SupportedBitness": "64",
              "RelativePath": "src",
              "LabVIEW_Project": "MyProject.lvproj",
              "Build_Spec": "My Build",
              "Major": 1,
              "Minor": 0,
              "Patch": 0,
              "Build": 42,
              "Commit": "${{ github.sha }}"
            }
```

### Cross‑platform matrix example (for actions that can run on Linux too)

```yaml
jobs:
  unit-tests:
    strategy:
      matrix:
        os: [windows-latest, ubuntu-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      - uses: ./actions/abstract-action
        with:
          action_name: run-unit-tests
          args_json: >
            {
              "MinimumSupportedLVVersion": "2021",
              "SupportedBitness": "64",
              "gcliPath": "/opt/gcli/bin"
            }
```

## Exit Codes & DryRun

Adapters return the original leaf scripts’ exit codes.

RunUnitTests preserves 0 (success), 2 (test failures), 3 (g‑cli error). A pretty table is printed via `Format‑UnitTestReport`, but exit codes are unchanged.

`DryRun` logs what would be executed and skips the leaf program.

## Logging

Control verbosity with `-LogLevel`:

- `ERROR`: quiet (no info/verbose)
- `WARN`: warnings & errors
- `INFO` (default): informational logs
- `DEBUG`: includes verbose logs

## Security

Prefer passing secrets via `${{ secrets.* }}` in workflows.

The adapters mask common secret keys (`token|secret|password|key`) in `DryRun` JSON logs.

## Adapters (MVP)

- `apply-vipc` → `actions/apply-vipc/ApplyVIPC.ps1`
- `build-lvlibp` → `actions/build-lvlibp/Build_lvlibp.ps1`
- `missing-in-project` → `actions/missing-in-project/Invoke-MissingInProjectCLI.ps1`
- `run-unit-tests` → `actions/run-unit-tests/RunUnitTests.ps1` (0/2/3 semantics + formatted report)

Add more by following the pattern in `OpenSourceActions.psm1`, exporting the function in `OpenSourceActions.psd1`, and registering it in `Invoke-OSAction.ps1`.

## Adding a New Action

- Create adapter in `actions/OpenSourceActions.psm1`.
- Strongly typed `param()`.
- Map canonical inputs → leaf script args.
- Respect `-DryRun`, return `[int]` exit code.
- Optional: accept `gcliPath` and prepend to `PATH`.
- Export it in `actions/OpenSourceActions.psd1` → `FunctionsToExport`.
- Register it in `actions/Invoke-OSAction.ps1` → `$Registry`.
- Test with Pester (see `tests/pester/Dispatcher.Tests.ps1`).

## SemVer Policy

- **MAJOR**: breaking changes (rename/remove actions; parameter type changes).
- **MINOR**: new actions or optional parameters.
- **PATCH**: backwards‑compatible bug fixes & docs.

Current module version: 1.0.0 (see `OpenSourceActions.psd1`).

## Troubleshooting

- Unknown `ActionName` → run `-ListActions`.
- Invalid JSON → fix `args_json` (the dispatcher validates and fails fast).
- Ignored unknown parameters → your `args_json` included keys not supported by the adapter; they were ignored with a warning.
- No output in `DryRun` → set `-LogLevel INFO` or `DEBUG`.

## Testing

Run the Pester suite (OS‑agnostic):

```powershell
pwsh -NoProfile -Command "Invoke-Pester -Path ./tests/pester -CI"
```

Manual tests that require LabVIEW + g‑cli are tagged `[Manual]` and can be run on your specialized setup.
