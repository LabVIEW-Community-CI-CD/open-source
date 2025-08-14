# prepare-labview-source

## Purpose

Run PrepareIESource.vi via g-cli to unzip components and configure LabVIEW for building.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version used to run g-cli.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Path to the repository root.
- **LabVIEW_Project** (`string`): Name of the LabVIEW project (without extension).
- **Build_Spec** (`string`): Name of the build specification to prepare.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName prepare-labview-source -ArgsJson '{
  "MinimumSupportedLVVersion": "2021",
  "SupportedBitness": "64",
  "RelativePath": ".",
  "LabVIEW_Project": "lv_icon_editor",
  "Build_Spec": "Editor Packed Library"
}'
```

## GitHub Action example

```yaml
- name: Prepare LabVIEW source
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: prepare-labview-source
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2021",
        "SupportedBitness": "64",
        "RelativePath": ".",
        "LabVIEW_Project": "lv_icon_editor",
        "Build_Spec": "Editor Packed Library"
      }
```

## Return Codes

- `0` – LabVIEW source prepared
- non‑zero – g-cli error preparing source

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

Source: [scripts/prepare-labview-source/](https://github.com/LabVIEW-Community-CI-CD/open-source-actions/tree/actions/scripts/prepare-labview-source/)
