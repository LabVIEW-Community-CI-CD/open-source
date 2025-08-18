# prepare-labview-source

## Purpose

Run PrepareIESource.vi via g-cli to unzip components and configure LabVIEW for building.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version used to run g-cli.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Path relative to the action's working directory. Use "." when the working directory is desired.
- **LabVIEW_Project** (`string`): Name of the LabVIEW project (without extension).
- **Build_Spec** (`string`): Name of the build specification to prepare.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName prepare-labview-source -ArgsJson '{
  "MinimumSupportedLVVersion": "2021",
  "SupportedBitness": "64",
  "WorkingDirectory": ".",
  "RelativePath": ".",
  "LabVIEW_Project": "lv_icon_editor",
  "Build_Spec": "Editor Packed Library"
}'
```

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `minimum_supported_lv_version` | `MinimumSupportedLVVersion` | Minimum LabVIEW version supported. |
| `supported_bitness` | `SupportedBitness` | "32" or "64" bitness of LabVIEW. |
| `relative_path` | `RelativePath` | Path relative to the working directory. Use '.' to refer to the working directory. |
| `labview_project` | `LabVIEW_Project` | Path to the LabVIEW project file. |
| `build_spec` | `Build_Spec` | Name of the build specification. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Base directory for the action; relative paths are resolved from here. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Prepare LabVIEW source
  uses: LabVIEW-Community-CI-CD/open-source-actions/prepare-labview-source@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    working_directory: '.'
    relative_path: '.'
    labview_project: 'lv_icon_editor'
    build_spec: 'Editor Packed Library'
```

## Return Codes

- `0` – LabVIEW source prepared
- non‑zero – g-cli error preparing source

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

See also: [scripts/prepare-labview-source/README.md](../../scripts/prepare-labview-source/README.md).
