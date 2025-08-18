# Add LabVIEW INI Token ⚙️

Invoke **`AddTokenToLabVIEW.ps1`** through a composite action to add a `Localhost.LibraryPaths` token to the LabVIEW INI file via **g-cli**.

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `minimum_supported_lv_version` | **Yes** | `2021` | LabVIEW major version used by g-cli. |
| `supported_bitness` | **Yes** | `32` or `64` | Target LabVIEW bitness. |
| `relative_path` | **Yes** | `${{ github.workspace }}` | Repository root on disk. |

## Quick-start

```yaml
- uses: ./.github/actions/add-token-to-labview
  with:
    minimum_supported_lv_version: 2024
    supported_bitness: 64
    relative_path: ${{ github.workspace }}
```

See also: [docs/actions/add-token-to-labview.md](../../docs/actions/add-token-to-labview.md)

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
