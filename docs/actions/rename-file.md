# rename-file

## Purpose

Rename a file if it exists.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **CurrentFilename** (`string`): Full path to the file to rename.
- **NewFilename** (`string`): New name (including path) for the file.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName rename-file -ArgsJson '{
  "CurrentFilename": "C:/path/lv_icon.lvlibp",
  "NewFilename": "lv_icon_x64.lvlibp"
}'
```

## GitHub Action example

```yaml
- name: Rename file
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: rename-file
    args_json: >-
      {
        "CurrentFilename": "C:/path/lv_icon.lvlibp",
        "NewFilename": "lv_icon_x64.lvlibp"
      }
```

## Return Codes

- `0` – file renamed successfully
- non‑zero – file not found or rename failed

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

Source: [scripts/rename-file/](https://github.com/LabVIEW-Community-CI-CD/open-source-actions/tree/actions/scripts/rename-file/)
