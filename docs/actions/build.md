# build

## Purpose

Automate building the LabVIEW Icon Editor project, including cleaning, building libraries, and packaging.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **RelativePath** (`string`): Path relative to the action's working directory. Use "." when the working directory is desired.
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
  "WorkingDirectory": ".",
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

## GitHub Action inputs

GitHub Action inputs are provided in `snake_case`, while CLI parameters use `PascalCase`. The table below maps each input to its corresponding CLI parameter. For details on shared CLI flags, see [Common parameters](../common-parameters.md).

| Input | CLI parameter | Description |
| --- | --- | --- |
| `relative_path` | `RelativePath` | Path relative to the working directory. Use '.' to refer to the working directory. |
| `major` | `Major` | Major version component. |
| `minor` | `Minor` | Minor version component. |
| `patch` | `Patch` | Patch version component. |
| `build` | `Build` | Build number. |
| `commit` | `Commit` | Commit identifier. |
| `labview_minor_revision` | `LabVIEWMinorRevision` | LabVIEW minor revision. |
| `company_name` | `CompanyName` | Company name for the build. |
| `author_name` | `AuthorName` | Author name for the build. |
| `gcli_path` | `gcliPath` | Optional path to the g-cli executable. |
| `working_directory` | `WorkingDirectory` | Base directory for the action; relative paths are resolved from here. |
| `log_level` | `LogLevel` | Verbosity level (ERROR\|WARN\|INFO\|DEBUG). |
| `dry_run` | `DryRun` | If true, simulate the action without side effects. |

## GitHub Action example

```yaml
- name: Build project
  uses: LabVIEW-Community-CI-CD/open-source-actions/build@v1
  with:
    working_directory: '.'
    relative_path: '.'
    major: 1
    minor: 0
    patch: 0
    build: 1
    commit: abcdef
    labview_minor_revision: '3'
    company_name: 'Acme Corp'
    author_name: 'Jane Doe'
```

## Return Codes

- `0` – build completed successfully
- non‑zero – build script or g-cli error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

See also: [scripts/build/README.md](../../scripts/build/README.md).
