# Generate Release Notes

This composite action creates a Markdown file summarizing commits since the last tag.
By default, it writes to `Tooling/deployment/release_notes.md`, which you can use when drafting changelogs or GitHub releases.

## Inputs

- `output_path` (optional): Path for the generated release notes file relative to the repository root. Defaults to `Tooling/deployment/release_notes.md`.

## Example Usage

```yaml
- name: Generate release notes
  uses: ./.github/actions/generate-release-notes
  with:
    output_path: Tooling/deployment/release_notes.md
```

See also: [docs/actions/generate-release-notes.md](../../docs/actions/generate-release-notes.md).
