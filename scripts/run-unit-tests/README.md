# Run Unit Tests ✅

Invoke **`RunUnitTests.ps1`** to execute LabVIEW unit tests and output a result table.
Reports are deleted when all tests pass; set `keep_report` to retain them.

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `minimum_supported_lv_version` | **Yes** | `2021` | LabVIEW major version. |
| `supported_bitness` | **Yes** | `32` or `64` | Target LabVIEW bitness. |
| `keep_report` | No | `true` | Skip cleanup so `UnitTestReport.xml` remains on disk. |

## Quick-start

```yaml
- uses: ./.github/actions/run-unit-tests
  with:
    minimum_supported_lv_version: 2024
    supported_bitness: 64
    # keep_report: true
```

See also: [docs/actions/run-unit-tests.md](../../docs/actions/run-unit-tests.md)

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
