# Restore LabVIEW Setup ↩️

Run **`RestoreSetupLVSource.ps1`** to restore packaged LabVIEW sources and remove INI tokens.

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `minimum_supported_lv_version` | **Yes** | `2021` | LabVIEW major version. |
| `supported_bitness` | **Yes** | `32` or `64` | Target LabVIEW bitness. |
| `relative_path` | **Yes** | `${{ github.workspace }}` | Repository root path. |
| `labview_project` | **Yes** | `lv_icon_editor` | Project name (no extension). |
| `build_spec` | **Yes** | `Editor Packed Library` | Build specification name. |

## Quick-start

```yaml
- uses: ./.github/actions/restore-setup-lv-source
  with:
    minimum_supported_lv_version: 2024
    supported_bitness: 64
    relative_path: ${{ github.workspace }}
    labview_project: lv_icon_editor
    build_spec: "Editor Packed Library"
```

See also: [docs/actions/restore-setup-lv-source.md](../../docs/actions/restore-setup-lv-source.md)

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
