# LabVIEW Community CI/CD — Unified Dispatcher

PowerShell-based actions for LabVIEW build and test tasks exposed through a single dispatcher script. See the [documentation site](https://open-source-actions.github.io/open-source-actions/) for setup and action reference. The [quickstart](docs/quickstart.md) shows a full example and [Unified Dispatcher](docs/UnifiedDispatcher.md) describes how the dispatcher works. For an overview of the project's architecture, see [docs/architecture.md](docs/architecture.md).

## Usage

**Composite action**

```yaml
- name: Run tests
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: run-unit-tests
    args_json: '{ "MinimumSupportedLVVersion": "2021", "SupportedBitness": "64" }'
```

**CLI**

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{ "MinimumSupportedLVVersion": "2021", "SupportedBitness": "64" }'
```

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for general guidelines and [docs/contributing-docs.md](docs/contributing-docs.md) for documentation rules. To preview docs locally:

```bash
pip install mkdocs mkdocs-material
mkdocs serve
```
