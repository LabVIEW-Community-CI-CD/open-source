# set-development-mode

## Purpose

Configure the repository for development mode by removing packed libraries, adding tokens, preparing sources, and closing LabVIEW.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **RelativePath** (`string`): Path to the repository root.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName set-development-mode -ArgsJson '{
  "RelativePath": "."
}'
```

## GitHub Action example

```yaml
- name: Set development mode
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: set-development-mode
    args_json: >-
      {
        "RelativePath": "."
      }
```

## Return Codes

- `0` – development mode enabled
- non‑zero – script or g-cli error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

Source: [scripts/set-development-mode/](../../scripts/set-development-mode/)
