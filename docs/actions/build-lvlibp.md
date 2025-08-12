# build-lvlibp

## Purpose
Build a LabVIEW project’s build specification into a Packed Project Library (.lvlibp).

## Parameters

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
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: build-lvlibp
    args_json: >-
      {
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
      }
```

## Return Codes
- `0` – build succeeded
- `1` – build failed or g-cli error
