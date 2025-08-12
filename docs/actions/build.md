# build

## Purpose

Automate building the LabVIEW Icon Editor project, including cleaning, building libraries, and packaging.

## Parameters

### Required

- **RelativePath** (`string`): Path to the repository root.
- **Major** (`int`): Major version component.
- **Minor** (`int`): Minor version component.
- **Patch** (`int`): Patch version component.
- **Build** (`int`): Build number component.
- **Commit** (`string`): Commit identifier embedded in the build.
- **LabVIEWMinorRevision** (`string`): LabVIEW minor revision (e.g., "3").
- **CompanyName** (`string`): Name of the company for metadata.
- **AuthorName** (`string`): Author or organization name for metadata.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName build -ArgsJson '{
  "RelativePath": ".",
  "Major": 1,
  "Minor": 0,
  "Patch": 0,
  "Build": 1,
  "Commit": "abcdef",
  "LabVIEWMinorRevision": "3",
  "CompanyName": "Acme Corp",
  "AuthorName": "Jane Doe"
}'
```

## GitHub Action example

```yaml
- name: Build project
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: build
    args_json: >-
      {
        "RelativePath": ".",
        "Major": 1,
        "Minor": 0,
        "Patch": 0,
        "Build": 1,
        "Commit": "abcdef",
        "LabVIEWMinorRevision": "3",
        "CompanyName": "Acme Corp",
        "AuthorName": "Jane Doe"
      }
```

## Return Codes

- `0` – build completed successfully
- non‑zero – build script or g-cli error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).
