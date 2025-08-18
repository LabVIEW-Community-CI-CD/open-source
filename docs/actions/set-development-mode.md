# set-development-mode

## Purpose

Configure the repository for development mode by removing packed libraries, adding tokens, preparing sources, and closing LabVIEW.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **RelativePath** (`string`): Path relative to the action's working directory. Use "." when the working directory is desired.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName set-development-mode -ArgsJson '{
  "WorkingDirectory": ".",
  "RelativePath": "."
}'
```

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `relative_path` | `RelativePath` | Path relative to the working directory. Use '.' to refer to the working directory. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Base directory for the action; relative paths are resolved from here. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Set development mode
  uses: LabVIEW-Community-CI-CD/open-source-actions/set-development-mode@v1
  with:
    working_directory: '.'
    relative_path: '.'
```

## Return Codes

- `0` – development mode enabled
- non‑zero – script or g-cli error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

See also: [scripts/set-development-mode/README.md](../../scripts/set-development-mode/README.md).
