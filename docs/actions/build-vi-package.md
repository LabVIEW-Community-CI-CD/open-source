# build-vi-package

## Purpose

Update VIPB display information and build a VI package using g-cli.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): Minimum LabVIEW version supported by the package.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **LabVIEWMinorRevision** (`string`): LabVIEW minor revision (e.g., "3").
- **RelativePath** (`string`): Repository root used to resolve paths.
- **VIPBPath** (`string`): Relative path to the VIPB file to build.
- **Major** (`int`): Major version component.
- **Minor** (`int`): Minor version component.
- **Patch** (`int`): Patch version component.
- **Build** (`int`): Build number component.
- **Commit** (`string`): Commit identifier for metadata.
- **DisplayInformationJSON** (`string`): JSON string to merge into the VIPB display information.

### Optional

- **ReleaseNotesFile** (`string`): Path to a release notes file included in the package.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName build-vi-package -ArgsJson '{
  "MinimumSupportedLVVersion": "2023",
  "SupportedBitness": "64",
  "LabVIEWMinorRevision": "3",
  "RelativePath": ".",
  "VIPBPath": "Tooling/deployment/NI Icon editor.vipb",
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
- name: Build VI Package
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: build-vi-package
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2023",
        "SupportedBitness": "64",
        "LabVIEWMinorRevision": "3",
        "RelativePath": ".",
        "VIPBPath": "Tooling/deployment/NI Icon editor.vipb",
        "Major": 1,
        "Minor": 0,
        "Patch": 0,
        "Build": 2,
        "Commit": "abcdef",
        "DisplayInformationJSON": "{\"Package Version\":{\"major\":1,\"minor\":0,\"patch\":0,\"build\":2}}"
      }
```

## Return Codes

- `0` – package built successfully
- non‑zero – g-cli or build error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

Source: [scripts/build-vi-package/](https://github.com/LabVIEW-Community-CI-CD/open-source-actions/tree/actions/scripts/build-vi-package/)
