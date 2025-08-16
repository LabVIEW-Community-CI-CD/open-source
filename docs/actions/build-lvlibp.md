# build-lvlibp

## Purpose

Build a LabVIEW project’s build specification into a Packed Project Library (.lvlibp).

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version used for the build.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Working directory or project root.
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

## GitHub Action example

```yaml
- name: Build Packed Library
  uses: LabVIEW-Community-CI-CD/open-source-actions/build-lvlibp@v1
  with:
    minimum_supported_lv_version: '2020'
    supported_bitness: '64'
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
