# close-labview

## Purpose

Gracefully close a running LabVIEW instance via g-cli.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version to close.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName close-labview -ArgsJson '{
  "MinimumSupportedLVVersion": "2021",
  "SupportedBitness": "64"
}'
```

## GitHub Action example

```yaml
- name: Close LabVIEW
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: close-labview
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2021",
        "SupportedBitness": "64"
      }
```

## Return Codes

- `0` – LabVIEW closed successfully
- non‑zero – g-cli error closing LabVIEW

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

Source: [scripts/close-labview/](https://github.com/LabVIEW-Community-CI-CD/open-source-actions/tree/actions/scripts/close-labview/)
