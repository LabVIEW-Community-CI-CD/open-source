# Open Source LabVIEW Actions

Open Source LabVIEW Actions provides typed GitHub Action wrappers around a unified PowerShell dispatcher for LabVIEW CI/CD tasks. Each adapter (for example `run-unit-tests`) is exposed as its own action and can be called from workflows with `uses: LabVIEW-Community-CI-CD/open-source-actions/<action>@v1`.

See the [documentation site](https://open-source-actions.github.io/open-source-actions/) for setup and action reference. The [quickstart](docs/quickstart.md) shows a full example and [Unified Dispatcher](docs/UnifiedDispatcher.md) describes how the dispatcher works. For an overview of the project's architecture, see [docs/architecture.md](docs/architecture.md). For a mapping of high-level requirements to the tests that verify them, see [docs/requirements.md](docs/requirements.md).

## Prerequisites

- PowerShell 7+ (`pwsh`)
- NI LabVIEW with command-line interface support (g-cli) for LabVIEW-based actions
- Supported platforms: Windows for LabVIEW tasks; PowerShell-only scripts also run on macOS and Linux

## GitHub Action usage

```yaml
- name: Run tests
  uses: LabVIEW-Community-CI-CD/open-source-actions/run-unit-tests@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
```

Each adapter has its own wrapper. Replace `run-unit-tests` with any action name listed in the [action reference](docs/index.md#action-reference). The wrappers translate the typed inputs above into the dispatcher.

Common optional inputs available on all wrappers:

| Name | Description |
| ---- | ----------- |
| `gcli_path` | Path to the g-cli executable when it is not on `PATH`. |
| `working_directory` | Directory where the action runs. |
| `log_level` | Verbosity level (`ERROR`, `WARN`, `INFO`, `DEBUG`). |
| `dry_run` | Simulate the action without side effects. |

### Examples

Run tests from a subfolder:

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/run-unit-tests@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    working_directory: src
```

Enable debug logging and perform a dry run:

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/run-unit-tests@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    log_level: DEBUG
    dry_run: true
  ```

## CLI/dispatcher usage

If you prefer or need to run tasks directly, call the dispatcher script yourself:

```powershell
$yaml = @'
MinimumSupportedLVVersion: "2021"
SupportedBitness: "64"
'@
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsYaml (ConvertFrom-Yaml $yaml)
```

You can also load arguments from a file:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsFile ./config/run-tests.yaml
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
