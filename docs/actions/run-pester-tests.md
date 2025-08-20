# run-pester-tests

## Purpose

Run PowerShell Pester tests in a repository.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **WorkingDirectory** (`string`): Path to the repository containing tests under `tests/pester`.

### Optional

None.

### GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `working_directory` | `WorkingDirectory` | Directory containing the repository under test. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## Examples

### CLI

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName run-pester-tests -ArgsJson '{
  "WorkingDirectory": "."
}'
```

### GitHub Action

```yaml
- name: Run Pester tests
  uses: LabVIEW-Community-CI-CD/open-source/run-pester-tests@v1
  with:
    working_directory: '.'
```

## Outputs

Running the action writes a `requirement-coverage.json` file to the working directory. The file lists each requirement ID discovered from test tags and whether its associated tests passed (`PASS`), failed (`FAIL`), or were not executed (`NOT_RUN`).

## Return Codes

- `0` – all tests passed
- non‑zero – tests failed or Pester error

See [run-pester-tests/action.yml](../../run-pester-tests/action.yml) and [scripts/run-pester-tests/RunPesterTests.ps1](../../scripts/run-pester-tests/RunPesterTests.ps1) for implementation details.

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

## See also

- [Workflow documentation](../workflows/run-pester-tests.md)
- [scripts/run-pester-tests/README.md](../../scripts/run-pester-tests/README.md)
