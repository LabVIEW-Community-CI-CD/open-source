# Run Pester Tests ✅

Invoke **`RunPesterTests.ps1`** to execute PowerShell Pester tests under `tests/pester`.
For full documentation, see [run-pester-tests action](../../docs/actions/run-pester-tests.md).

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `working_directory` | **Yes** | `.` | Path to the repository containing tests under `tests/pester`. |

## Quick-start

```yaml
- uses: ./.github/actions/run-pester-tests
  with:
    working_directory: '.'
```

See also: [docs/actions/run-pester-tests.md](../../docs/actions/run-pester-tests.md)

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
