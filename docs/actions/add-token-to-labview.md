# add-token-to-labview

## Purpose

Add a custom library path token to the LabVIEW INI file so LabVIEW can locate project libraries.

## Parameters

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version used to run g-cli.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.
- **RelativePath** (`string`): Repository root added to the INI token.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName add-token-to-labview -ArgsJson '{
  "MinimumSupportedLVVersion": "2021",
  "SupportedBitness": "64",
  "RelativePath": "."
}'
```

## GitHub Action example

```yaml
- name: Add library token
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: add-token-to-labview
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2021",
        "SupportedBitness": "64",
        "RelativePath": "."
      }
```

## Return Codes

- `0` – token added successfully
- non‑zero – g-cli error adding token

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).
