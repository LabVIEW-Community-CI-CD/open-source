# apply-vipc

## Purpose

Apply a VI Package Configuration (.vipc) file to a specific LabVIEW installation using g-cli.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version used to apply the VIPC.
- **VIP_LVVersion** (`string`): LabVIEW version the VIPC targets.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Path relative to the action's working directory. Use "." when the working directory is desired.
- **VIPCPath** (`string`): Path to the `.vipc` file to apply.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName apply-vipc -ArgsJson '{
  "MinimumSupportedLVVersion": "2019",
  "VIP_LVVersion": "2019",
  "SupportedBitness": "64",
  "WorkingDirectory": ".",
  "RelativePath": ".",
  "VIPCPath": "MyProject.vipc"
}'
```

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `minimum_supported_lv_version` | `MinimumSupportedLVVersion` | Minimum LabVIEW version supported. |
| `vip_lv_version` | `VIP_LVVersion` | LabVIEW version associated with the VI Package. |
| `supported_bitness` | `SupportedBitness` | "32" or "64" bitness of LabVIEW. |
| `relative_path` | `RelativePath` | Path relative to the working directory. Use '.' to refer to the working directory. |
| `vipc_path` | `VIPCPath` | Path to the VIPC file. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Base directory for the action; relative paths are resolved from here. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Apply VIPC
  uses: LabVIEW-Community-CI-CD/open-source-actions/apply-vipc@v1
  with:
    minimum_supported_lv_version: '2019'
    vip_lv_version: '2019'
    supported_bitness: '64'
    working_directory: '.'
    relative_path: '.'
    vipc_path: 'MyProject.vipc'
```

## Return Codes

- `0` – VIPC applied successfully
- `1` – error applying VIPC or invalid input

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

See also: [scripts/apply-vipc/README.md](../../scripts/apply-vipc/README.md).
