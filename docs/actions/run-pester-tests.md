# run-pester-tests

## Purpose

Run PowerShell Pester tests in a repository.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **WorkingDirectory** (`string`): Path to the repository containing tests under `tests/pester`.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName run-pester-tests -ArgsJson '{
  "WorkingDirectory": "."
}'
```

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `working_directory` | `WorkingDirectory` | Directory containing the repository under test. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Run Pester tests
  uses: LabVIEW-Community-CI-CD/open-source-actions/run-pester-tests@v1
  with:
    working_directory: '.'
```

## Return Codes

- `0` – all tests passed
- non‑zero – tests failed or Pester error

See [run-pester-tests/action.yml](../../run-pester-tests/action.yml) and [scripts/run-pester-tests/RunPesterTests.ps1](../../scripts/run-pester-tests/RunPesterTests.ps1) for implementation details.

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

See also: [scripts/run-pester-tests/README.md](../../scripts/run-pester-tests/README.md).
