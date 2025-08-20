# Open Source LabVIEW Actions

Open Source LabVIEW Actions provides typed GitHub Action wrappers around a unified PowerShell dispatcher for LabVIEW CI/CD tasks. Each adapter (for example `run-unit-tests`) is exposed as its own action and can be called from workflows with `uses: LabVIEW-Community-CI-CD/open-source-actions/<action>@v1`.

For setup and action reference, see the [documentation](docs/index.md). The [quickstart](docs/quickstart.md) shows a full example and [Unified Dispatcher](docs/UnifiedDispatcher.md) describes how the dispatcher works. For an overview of the project's architecture, see [docs/architecture.md](docs/architecture.md). For a mapping of high-level requirements to the tests that verify them, see [docs/requirements.md](docs/requirements.md).

## Prerequisites

- Node.js 24+ (run `npm install` after cloning to fetch tsx and other dependencies)
- PowerShell 7+ (`pwsh`)
- NI LabVIEW with command-line interface support (g-cli) for LabVIEW-based actions
- Supported platforms: Windows for LabVIEW tasks; PowerShell-only scripts also run on macOS and Linux

See [Environment Setup](docs/environment-setup.md) for installation steps and commands to verify each dependency.

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

For a full workflow example that chains multiple actions to build the LabVIEW Icon Editor, see [docs/quickstart.md#build-icon-editor](docs/quickstart.md#build-icon-editor).

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
Alternatively, load arguments from a JSON file:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsFile ./config/run-tests.json
```

By default the dispatcher ignores unknown parameters and emits a warning. Add `-FailOnUnknown` to treat unexpected parameters as errors:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson $json -FailOnUnknown
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

## Runner Types

Workflows distinguish between standard GitHub-hosted images and integration runners with preinstalled tooling. See [docs/runner-types.md](docs/runner-types.md) for a detailed comparison.

## Testing

Run the JavaScript tests and generate traceability artifacts with:

```bash
npm install
npm run test:ci
npm run derive:registry
TEST_RESULTS_GLOBS='test-results/*junit*.xml' npm run generate:summary
npm run check:traceability
```

`npm run test:ci` writes JUnit files to `test-results/`. [scripts/generate-ci-summary.ts](scripts/generate-ci-summary.ts) parses these results to build requirement traceability files in OS‑specific subdirectories (e.g., `artifacts/windows`, `artifacts/linux`) based on the `RUNNER_OS` environment variable. Commit `test-results/*` and `artifacts/linux/*` along with your source changes. The summary script searches `artifacts/` by default; set `TEST_RESULTS_GLOBS` if your reports are elsewhere.

Pester tests cover the dispatcher and helper modules. See [docs/testing-pester.md](docs/testing-pester.md) for guidelines on using the canonical argument helper and adding new tests. The GitHub runner installs Pester automatically; install it locally only if you plan to run the tests yourself:

```powershell
Install-Module Pester -Force -Scope CurrentUser
```

```powershell
$cfg = New-PesterConfiguration
$cfg.Run.Path = './tests/pester'
$cfg.TestResult.Enabled = $false
Invoke-Pester -Configuration $cfg
```

XML test result output is intentionally disabled.

## Test and Release Mode

Committing build artifacts together with a `release.json` file enables the
release pipeline. The `release.json` file supplies the JSON payload describing
the release:

```json
{"major":1,"minor":0,"patch":2,"title":"Release title"}
```

Ensure the build artifacts are present (for example under `artifacts/`) and
checked in alongside `release.json`. The `ci.yml` workflow runs first and, on
success, hands off to `release.yml` to publish the release. See
[Test and Release Mode](AGENTS.md#test-and-release-mode) for more details.

## Requirement Traceability

Each requirement is tracked as an issue or entry in
[`requirements.json`](requirements.json). Every code change must reference the
requirement it addresses, and each requirement must have at least one automated
test. The CI pipeline checks these links and reports missing associations. For a
full mapping of requirements to tests, see
[docs/requirements.md](docs/requirements.md).

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
