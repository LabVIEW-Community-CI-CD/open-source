# missing-in-project

## Purpose
Check that all files in a LabVIEW project are present by scanning for items missing from the `.lvproj`.

## Parameters

### Required
- **LVVersion** (`string`): LabVIEW version used to open the project.
- **Arch** (`string`): "32" or "64" bitness of LabVIEW.
- **ProjectFile** (`string`): Path to the project file to inspect.

### Optional
None.

## CLI example
```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName missing-in-project -ArgsJson '{
  "LVVersion": "2020",
  "Arch": "64",
  "ProjectFile": "MyProject.lvproj"
}'
```

## GitHub Action example
```yaml
- name: Check for Missing Project Items
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: missing-in-project
    args_json: >-
      {
        "LVVersion": "2020",
        "Arch": "64",
        "ProjectFile": "MyProject.lvproj"
      }
```

## Return Codes
- `0` – no missing files detected
- `1` – g-cli or VI error
- `2` – missing files found
