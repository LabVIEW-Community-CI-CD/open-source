# revert-development-mode

## Purpose

Restore the repository from development mode by restoring packaged sources and closing LabVIEW.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **RelativePath** (`string`): Path to the repository root.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName revert-development-mode -ArgsJson '{
  "RelativePath": "."
}'
```

## GitHub Action example

```yaml
- name: Revert development mode
  uses: LabVIEW-Community-CI-CD/open-source-actions/revert-development-mode@v1
  with:
    relative_path: '.'
```

## Return Codes

- `0` – reverted to packaged state
- non‑zero – script or g-cli error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).
