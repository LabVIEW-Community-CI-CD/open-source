# Open Source LabVIEW Actions

Open Source LabVIEW Actions is a composite GitHub Action that dispatches LabVIEW CI/CD tasks via PowerShell. See the [documentation site](https://open-source-actions.github.io/open-source-actions/) for setup and action reference. The [quickstart](docs/quickstart.md) shows a full example and [Unified Dispatcher](docs/UnifiedDispatcher.md) describes how the dispatcher works. For an overview of the project's architecture, see [docs/architecture.md](docs/architecture.md).

To inspect the action's source and full schema, see [action.yml](action.yml).

## Prerequisites

- PowerShell 7+ (`pwsh`)
- NI LabVIEW with command-line interface support (g-cli) for LabVIEW-based actions
- Supported platforms: Windows for LabVIEW tasks; PowerShell-only scripts also run on macOS and Linux

## GitHub Action usage

```yaml
- name: Run tests
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: run-unit-tests
    args_json: '{ "MinimumSupportedLVVersion": "2021", "SupportedBitness": "64" }'
```

This composite action wraps the dispatcher script [`actions/Invoke-OSAction.ps1`](actions/Invoke-OSAction.ps1). When the action runs it calls this script behind the scenes to execute the selected task.

### Inputs

| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| `action_name` | yes | – | Name of the action to execute (e.g. `run-unit-tests`). |
| `args_json` | no | `{}` | JSON string of arguments for the selected action. Use to pass parameters to the action. |
| `working_directory` | no | _(none)_ | Directory where the action runs. Set when your project files are not at the repository root. |
| `log_level` | no | `INFO` | Verbosity level (`ERROR`, `WARN`, `INFO`, `DEBUG`). Increase to `DEBUG` for troubleshooting. |
| `dry_run` | no | `false` | Simulate the action without side effects. Helpful for verifying inputs. |

#### Examples

Run tests from a subfolder:

```yaml
- name: Run tests in module
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: run-unit-tests
    working_directory: src
```

Enable debug logging and perform a dry run:

```yaml
- name: Dry run with debug logs
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: run-unit-tests
    log_level: DEBUG
    dry_run: true
```

### Outputs

This action does not emit outputs. Check logs or uploaded artifacts for results.

## CLI/dispatcher usage

If you prefer or need to run tasks directly, call the dispatcher script yourself:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{ "MinimumSupportedLVVersion": "2021", "SupportedBitness": "64" }'
```

### Discovering actions

List all available actions:

```powershell
pwsh actions/Invoke-OSAction.ps1 -ListActions
```

Get details about a specific action:

```powershell
pwsh actions/Invoke-OSAction.ps1 -Describe run-unit-tests
```

## Testing

Run the JavaScript tests with:

```bash
npm test
```

For CI, `npm run test:ci` emits a JUnit XML report that `scripts/generate-ci-summary.ts` parses to build the step summary and requirement traceability files. The script also renders action documentation from the templates in `doc-templates/` and packages the generated Markdown into the build artifacts.

Pester tests cover the dispatcher and helper modules. See [docs/testing-pester.md](docs/testing-pester.md) for guidelines on using the canonical argument helper and adding new tests. Run them with:

```powershell
Invoke-Pester -CI -Path ./tests/pester
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for general guidelines and [docs/contributing-docs.md](docs/contributing-docs.md) for documentation rules.

To preview docs locally:

```bash
pip install mkdocs mkdocs-material
mkdocs serve
```
