# modify-vipb-display-info

## Purpose

Update display information in a VIPB file and rebuild the VI package.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Path relative to the action's working directory. Use "." when the working directory is desired.
- **VIPBPath** (`string`): Relative path to the VIPB file.
- **MinimumSupportedLVVersion** (`string`): Minimum LabVIEW version supported by the package.
- **LabVIEWMinorRevision** (`string`): LabVIEW minor revision (e.g., "3").
- **Major** (`int`): Major version component.
- **Minor** (`int`): Minor version component.
- **Patch** (`int`): Patch version component.
- **Build** (`int`): Build number component.
- **Commit** (`string`): Commit identifier for metadata.
- **DisplayInformationJSON** (`string`): JSON string to merge into VIPB display information.

### Optional

- **ReleaseNotesFile** (`string`): Path to a release notes file injected into the build.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName modify-vipb-display-info -ArgsJson '{
  "SupportedBitness": "64",
  "WorkingDirectory": ".",
  "RelativePath": ".",
  "VIPBPath": "Tooling/deployment/NI Icon editor.vipb",
  "MinimumSupportedLVVersion": "2023",
  "LabVIEWMinorRevision": "3",
  "Major": 1,
  "Minor": 0,
  "Patch": 0,
  "Build": 2,
  "Commit": "abcdef",
  "DisplayInformationJSON": "{\"Package Version\":{\"major\":1,\"minor\":0,\"patch\":0,\"build\":2}}"
}'
```

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `supported_bitness` | `SupportedBitness` | "32" or "64" bitness of LabVIEW. |
| `relative_path` | `RelativePath` | Path relative to the working directory. Use '.' to refer to the working directory. |
| `vipb_path` | `VIPBPath` | Path to the VIPB file. |
| `minimum_supported_lv_version` | `MinimumSupportedLVVersion` | Minimum LabVIEW version supported. |
| `labview_minor_revision` | `LabVIEWMinorRevision` | LabVIEW minor revision. |
| `major` | `Major` | Major version component. |
| `minor` | `Minor` | Minor version component. |
| `patch` | `Patch` | Patch version component. |
| `build` | `Build` | Build number. |
| `commit` | `Commit` | Commit identifier. |
| `display_information_json` | `DisplayInformationJSON` | JSON string of display information. |
| `release_notes_file` | `ReleaseNotesFile` | Optional path to release notes file. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Base directory for the action; relative paths are resolved from here. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Modify VIPB display info
  uses: LabVIEW-Community-CI-CD/open-source-actions/modify-vipb-display-info@v1
  with:
    supported_bitness: '64'
    working_directory: '.'
    relative_path: '.'
    vipb_path: 'Tooling/deployment/NI Icon editor.vipb'
    minimum_supported_lv_version: '2023'
    labview_minor_revision: '3'
    major: 1
    minor: 0
    patch: 0
    build: 2
    commit: abcdef
    display_information_json: '{"Package Version":{"major":1,"minor":0,"patch":0,"build":2}}'
```

## Return Codes

- `0` – display information updated
- non‑zero – g-cli or build error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

See also: [scripts/modify-vipb-display-info/README.md](../../scripts/modify-vipb-display-info/README.md).
