# Revert Development Mode 🔄

Invoke **`RevertDevelopmentMode.ps1`** to restore packaged sources after development work.

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `relative_path` | **Yes** | `${{ github.workspace }}` | Repository root path. |

## Quick-start

```yaml
- uses: ./.github/actions/revert-development-mode
  with:
    relative_path: ${{ github.workspace }}
```

See also: [docs/actions/revert-development-mode.md](../../docs/actions/revert-development-mode.md)

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
