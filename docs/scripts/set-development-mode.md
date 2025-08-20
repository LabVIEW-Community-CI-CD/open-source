# Set Development Mode 🔧

Execute **`Set_Development_Mode.ps1`** to prepare the repository for active development.

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `relative_path` | **Yes** | `${{ github.workspace }}` | Repository root path. |

## Quick-start

```yaml
- uses: ./.github/actions/set-development-mode
  with:
    relative_path: ${{ github.workspace }}
```

See also: [docs/actions/set-development-mode.md](../actions/set-development-mode.md)

## Error handling

Failures produce the message `An unexpected error occurred during script execution: <details>` and the script exits with a non-zero status.

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
