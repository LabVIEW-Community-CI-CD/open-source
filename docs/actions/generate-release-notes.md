# generate-release-notes

## Purpose

Generate release notes from the git history and write them to a markdown file.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

None.

### Optional

- **OutputPath** (`string`): Path to write the release notes file (default `Tooling/deployment/release_notes.md`).

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName generate-release-notes -ArgsJson '{
  "OutputPath": "Tooling/deployment/release_notes.md"
}'
```

## GitHub Action example

```yaml
- name: Generate release notes
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: generate-release-notes
    args_json: >-
      {
        "OutputPath": "Tooling/deployment/release_notes.md"
      }
```

## Return Codes

- `0` – release notes generated
- non‑zero – git error generating notes

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

Source: [scripts/generate-release-notes/](../../scripts/generate-release-notes/)
