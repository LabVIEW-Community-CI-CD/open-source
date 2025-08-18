# Open Source LabVIEW Actions

Open Source LabVIEW Actions provides typed GitHub Action wrappers around a unified PowerShell dispatcher for LabVIEW CI/CD tasks. Each adapter (for example `run-unit-tests`) is exposed as its own action and can be called from workflows with `uses: LabVIEW-Community-CI-CD/open-source-actions/<action>@v1`.

For setup and action reference, see the [documentation](docs/index.md). The [quickstart](docs/quickstart.md) shows a full example and [Unified Dispatcher](docs/UnifiedDispatcher.md) describes how the dispatcher works. For an overview of the project's architecture, see [docs/architecture.md](docs/architecture.md). For a mapping of high-level requirements to the tests that verify them, see [docs/requirements.md](docs/requirements.md).

## Prerequisites

- Node.js 24+ (run `npm install` after cloning to fetch tsx and other dependencies)
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

Build Icon Editor:

Chain the [apply-vipc](docs/actions/apply-vipc.md), [set-development-mode](docs/actions/set-development-mode.md), [build](docs/actions/build.md), and [revert-development-mode](docs/actions/revert-development-mode.md) actions to build the LabVIEW Icon Editor:

```yaml
- uses: actions/checkout@v4
  with:
    repository: LabVIEW-Community-CI-CD/labview-icon-editor
    path: labview-icon-editor
- uses: LabVIEW-Community-CI-CD/open-source-actions/apply-vipc@v1
  with:
    minimum_supported_lv_version: '2021'
    vip_lv_version: '2021'
    supported_bitness: '64'
    relative_path: labview-icon-editor
    vipc_path: labview-icon-editor/.github/actions/apply-vipc/runner_dependencies.vipc
- uses: LabVIEW-Community-CI-CD/open-source-actions/set-development-mode@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    relative_path: labview-icon-editor
- uses: LabVIEW-Community-CI-CD/open-source-actions/build@v1
  with:
    relative_path: labview-icon-editor
    major: 1
    minor: 0
    patch: 0
    build: 0
    commit: abcdef
    labview_minor_revision: '3'
    company_name: 'Acme Corp'
    author_name: 'Jane Doe'
- uses: LabVIEW-Community-CI-CD/open-source-actions/revert-development-mode@v1
  with:
    relative_path: labview-icon-editor
```

## CLI/dispatcher usage

If you prefer or need to run tasks directly, serialize arguments as JSON and call the dispatcher script [actions/Invoke-OSAction.ps1](actions/Invoke-OSAction.ps1) yourself:

```powershell
$json = @'
{
  "MinimumSupportedLVVersion": "2021",
  "SupportedBitness": "64"
}
'@
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson $json
```
YAML conversion via `ConvertFrom-Yaml` is no longer required. You can also load arguments from a JSON file:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsFile ./config/run-tests.json
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
npm install
npm test
```

For CI, `npm run test:ci` emits a JUnit XML report that [scripts/generate-ci-summary.ts](scripts/generate-ci-summary.ts) parses to build requirement traceability files in OS‑specific subdirectories (e.g., `artifacts/windows`, `artifacts/linux`) based on the `RUNNER_OS` environment variable.

Pester tests cover the dispatcher and helper modules. See [docs/testing-pester.md](docs/testing-pester.md) for guidelines on using the canonical argument helper and adding new tests. Run them with:

```powershell
$cfg = New-PesterConfiguration
$cfg.Run.Path = './tests/pester'
$cfg.TestResult.Enabled = $false
Invoke-Pester -Configuration $cfg
```

XML test result output is intentionally disabled.

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for general guidelines and [docs/contributing-docs.md](docs/contributing-docs.md) for documentation rules.

To preview docs locally:

```bash
pip install mkdocs mkdocs-material
mkdocs serve
```

## Troubleshooting

If npm prints `npm warn Unknown env config "http-proxy"`, remove the
`npm_config_http_proxy` environment variable or replace it with
`npm_config_proxy`/`npm_config_https_proxy`.

Node.js 24+ removes legacy constants like `fs.R_OK`. Scripts and patches in
this repository rely on `fs.constants.R_OK` to remain compatible with newer
Node releases.
