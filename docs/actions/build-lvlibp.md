# build-lvlibp

## Purpose

Build a LabVIEW project’s build specification into a Packed Project Library (.lvlibp).

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version used for the build.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Path relative to the action's working directory. Use "." when the working directory is desired.
- **LabVIEW_Project** (`string`): Path to the LabVIEW project (.lvproj).
- **Build_Spec** (`string`): Name of the build specification to execute.
- **Major** (`int`): Major version number.
- **Minor** (`int`): Minor version number.
- **Patch** (`int`): Patch version number.
- **Build** (`int`): Build number.
- **Commit** (`string`): Commit identifier embedded in the build.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName build-lvlibp -ArgsJson '{
  "MinimumSupportedLVVersion": "2020",
  "SupportedBitness": "64",
  "WorkingDirectory": ".",
  "RelativePath": ".",
  "LabVIEW_Project": "Source/MyProject.lvproj",
  "Build_Spec": "PackedLib Build",
  "Major": 1,
  "Minor": 0,
  "Patch": 0,
  "Build": 123,
  "Commit": "abcdef"
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
| `major` | `Major` | Major version component. |
| `minor` | `Minor` | Minor version component. |
| `patch` | `Patch` | Patch version component. |
| `build` | `Build` | Build number. |
| `commit` | `Commit` | Commit identifier. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Base directory for the action; relative paths are resolved from here. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Build Packed Library
  uses: LabVIEW-Community-CI-CD/open-source-actions/build-lvlibp@v1
  with:
    minimum_supported_lv_version: '2020'
    supported_bitness: '64'
    working_directory: '.'
    relative_path: '.'
    labview_project: 'Source/MyProject.lvproj'
    build_spec: 'PackedLib Build'
    major: 1
    minor: 0
    patch: 0
    build: 123
    commit: abcdef
```

## Return Codes

- `0` – build succeeded
- `1` – build failed or g-cli error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

See also: [scripts/build-lvlibp/README.md](../../scripts/build-lvlibp/README.md).
