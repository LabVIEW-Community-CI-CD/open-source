# add-token-to-labview

## Purpose

Add a custom library path token to the LabVIEW INI file so LabVIEW can locate project libraries.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version used to run g-cli.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Path relative to the action's working directory. Use "." when the working directory is desired.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName add-token-to-labview -ArgsJson '{
  "MinimumSupportedLVVersion": "2021",
  "SupportedBitness": "64",
  "WorkingDirectory": ".",
  "RelativePath": "."
}'
```

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `minimum_supported_lv_version` | `MinimumSupportedLVVersion` | Minimum LabVIEW version supported. |
| `supported_bitness` | `SupportedBitness` | "32" or "64" bitness of LabVIEW. |
| `relative_path` | `RelativePath` | Path relative to the working directory. Use '.' to refer to the working directory. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Base directory for the action; relative paths are resolved from here. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Add library token
  uses: LabVIEW-Community-CI-CD/open-source-actions/add-token-to-labview@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    working_directory: '.'
    relative_path: '.'
```

## Return Codes

- `0` – token added successfully
- non‑zero – g-cli error adding token

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

See also: [scripts/add-token-to-labview/README.md](../../scripts/add-token-to-labview/README.md).
