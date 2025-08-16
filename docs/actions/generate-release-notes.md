# generate-release-notes

## Purpose

Generate release notes from the git history and write them to a markdown file.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

None.

### Optional

- **OutputPath** (`string`): Path to write the release notes file (default `Tooling/deployment/release_notes.md`).

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName generate-release-notes -ArgsJson '{
  "OutputPath": "Tooling/deployment/release_notes.md"
}'
```

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `output_path` | `OutputPath` | Path to output markdown file. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Working directory where the action will run. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Generate release notes
  uses: LabVIEW-Community-CI-CD/open-source-actions/generate-release-notes@v1
  with:
    output_path: 'Tooling/deployment/release_notes.md'
```

## Return Codes

- `0` – release notes generated
- non‑zero – git error generating notes

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).
