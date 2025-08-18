# Close LabVIEW 💤

Run **`Close_LabVIEW.ps1`** to terminate a running LabVIEW instance via g-cli.

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `minimum_supported_lv_version` | **Yes** | `2021` | LabVIEW major version to close. |
| `supported_bitness` | **Yes** | `32` or `64` | Target LabVIEW bitness. |

## Quick-start

```yaml
- uses: ./.github/actions/close-labview
  with:
    minimum_supported_lv_version: 2024
    supported_bitness: 64
```

See also: [docs/actions/close-labview.md](../../docs/actions/close-labview.md)

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
