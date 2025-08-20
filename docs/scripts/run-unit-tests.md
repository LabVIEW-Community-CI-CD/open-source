# Run Unit Tests ✅

Invoke **`RunUnitTests.ps1`** to execute LabVIEW unit tests and output a result table.
The script copies `UnitTestReport.xml` to `artifacts/unit-tests/UnitTestReport.xml` for later use.

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `minimum_supported_lv_version` | **Yes** | `2021` | LabVIEW major version. |
| `supported_bitness` | **Yes** | `32` or `64` | Target LabVIEW bitness. |

## Quick-start

```yaml
- uses: ./.github/actions/run-unit-tests
  with:
    minimum_supported_lv_version: 2024
    supported_bitness: 64
```

See also: [docs/actions/run-unit-tests.md](../actions/run-unit-tests.md)

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
