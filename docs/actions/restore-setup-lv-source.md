# restore-setup-lv-source

## Purpose

Restore the LabVIEW source setup by unzipping the LabVIEW Icon API and removing the INI token.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version used to run g-cli.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Path to the repository root.
- **LabVIEW_Project** (`string`): Name of the LabVIEW project (without extension).
- **Build_Spec** (`string`): Build specification name within the project.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName restore-setup-lv-source -ArgsJson '{
  "MinimumSupportedLVVersion": "2021",
  "SupportedBitness": "64",
  "RelativePath": ".",
  "LabVIEW_Project": "lv_icon_editor",
  "Build_Spec": "Editor Packed Library"
}'
```

## GitHub Action example

```yaml
- name: Restore LabVIEW setup
  uses: LabVIEW-Community-CI-CD/open-source-actions/restore-setup-lv-source@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    relative_path: '.'
    labview_project: 'lv_icon_editor'
    build_spec: 'Editor Packed Library'
```

## Return Codes

- `0` – setup restored
- non‑zero – g-cli error restoring setup

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).
