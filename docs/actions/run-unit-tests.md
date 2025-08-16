# run-unit-tests

## Purpose

Run LabVIEW unit tests via the LabVIEW Unit Test Framework CLI and report pass/fail/error using standard exit codes.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version for the test run.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.

### Optional

None.

## CLI example

```powershell
$yaml = @'
MinimumSupportedLVVersion: "2020"
SupportedBitness: "64"
'@
pwsh -File actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsYaml (ConvertFrom-Yaml $yaml)
```

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `minimum_supported_lv_version` | `MinimumSupportedLVVersion` | LabVIEW version for the test run. |
| `supported_bitness` | `SupportedBitness` | "32" or "64" bitness of LabVIEW. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Working directory where the action will run. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Run LabVIEW Unit Tests
  uses: LabVIEW-Community-CI-CD/open-source-actions/run-unit-tests@v1
  with:
    minimum_supported_lv_version: '2020'
    supported_bitness: '64'
```

## Return Codes

- `0` – all tests passed
- `2` – tests failed
- `3` – g-cli or test run error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).
