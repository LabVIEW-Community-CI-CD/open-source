# modify-vipb-display-info

## Purpose

Update display information in a VIPB file and rebuild the VI package.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Path to the repository root.
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

## GitHub Action example

```yaml
- name: Modify VIPB display info
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: modify-vipb-display-info
    args_json: >-
      {
        "SupportedBitness": "64",
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
      }
```

## Return Codes

- `0` – display information updated
- non‑zero – g-cli or build error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

Source: [scripts/modify-vipb-display-info/](../../scripts/modify-vipb-display-info/)
