# Unified LabVIEW Action

Unified LabVIEW Action is a composite GitHub Action that dispatches LabVIEW CI/CD tasks via PowerShell. See the [documentation site](https://open-source-actions.github.io/open-source-actions/) for setup and action reference. The [quickstart](docs/quickstart.md) shows a full example and [Unified Dispatcher](docs/UnifiedDispatcher.md) describes how the dispatcher works. For an overview of the project's architecture, see [docs/architecture.md](docs/architecture.md).

## Prerequisites

- PowerShell 7+ (`pwsh`)
- NI LabVIEW with command-line interface support (g-cli) for LabVIEW-based actions
- Supported platforms: Windows for LabVIEW tasks; PowerShell-only scripts also run on macOS and Linux

## Usage

**Composite action**

```yaml
- name: Run tests
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: run-unit-tests
    args_json: '{ "MinimumSupportedLVVersion": "2021", "SupportedBitness": "64" }'
```

**CLI**

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{ "MinimumSupportedLVVersion": "2021", "SupportedBitness": "64" }'
```

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

### Discovering actions

List all available actions:

```powershell
pwsh actions/Invoke-OSAction.ps1 -ListActions
```

Get details about a specific action:

```powershell
pwsh actions/Invoke-OSAction.ps1 -Describe run-unit-tests
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for general guidelines and [docs/contributing-docs.md](docs/contributing-docs.md) for documentation rules.

Run the JavaScript tests with:

```bash
npm test
```

To preview docs locally:

```bash
pip install mkdocs mkdocs-material
mkdocs serve
```
