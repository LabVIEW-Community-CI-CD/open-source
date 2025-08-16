# close-labview

## Purpose

Gracefully close a running LabVIEW instance via g-cli.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`, alias `minimum_supported_lv_version`): LabVIEW version to close.
- **SupportedBitness** (`string`, alias `supported_bitness`): "32" or "64" bitness of LabVIEW.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName close-labview -ArgsJson '{
  "minimum_supported_lv_version": "2021",
  "supported_bitness": "64"
}'
```

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `minimum_supported_lv_version` | `MinimumSupportedLVVersion` | Minimum LabVIEW version supported. |
| `supported_bitness` | `SupportedBitness` | "32" or "64" bitness of LabVIEW. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Working directory where the action will run. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Close LabVIEW
  uses: LabVIEW-Community-CI-CD/open-source-actions/close-labview@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
```

## Return Codes

- `0` – LabVIEW closed successfully
- non‑zero – g-cli error closing LabVIEW

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).
