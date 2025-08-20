# Full Build 🛠️

Runs **`Build.ps1`** to clean, compile, and package the LabVIEW Icon Editor.
Each build records provenance by renaming output artifacts to include the
build number and commit SHA and by writing an `artifact-manifest.json` file that
maps the generated artifacts back to the source commit.

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `relative_path` | **Yes** | `${{ github.workspace }}` | Repository root on disk. |
| `major` | **Yes** | `1` | Major version number. |
| `minor` | **Yes** | `0` | Minor version number. |
| `patch` | **Yes** | `0` | Patch version number. |
| `build` | **Yes** | `1` | Build number. |
| `commit` | **Yes** | `abcdef` | Commit identifier embedded in metadata. |
| `labview_minor_revision` | No (defaults to `3`) | `3` | LabVIEW minor revision. |
| `company_name` | **Yes** | `Acme Corp` | Company for display info. |
| `author_name` | **Yes** | `Jane Doe` | Author for display info. |

## Quick-start

```yaml
- uses: ./.github/actions/build
  with:
    relative_path: ${{ github.workspace }}
    major: 1
    minor: 0
    patch: 0
    build: ${{ github.run_number }}
    commit: ${{ github.sha }}
    company_name: Example Co
    author_name: CI
```

See also: [docs/actions/build.md](../actions/build.md)

## Error handling

On failure the script outputs `An unexpected error occurred during script execution: <details>` and returns a non-zero exit code.

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
