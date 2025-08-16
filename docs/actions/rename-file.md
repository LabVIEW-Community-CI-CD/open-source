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

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `current_filename` | `CurrentFilename` | Existing file name. |
| `new_filename` | `NewFilename` | New file name. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Working directory where the action will run. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Rename file
  uses: LabVIEW-Community-CI-CD/open-source-actions/rename-file@v1
  with:
    current_filename: 'C:/path/lv_icon.lvlibp'
    new_filename: 'lv_icon_x64.lvlibp'
```

## Return Codes

- `0` – file renamed successfully
- non‑zero – file not found or rename failed

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).
