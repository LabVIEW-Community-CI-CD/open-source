# \<action-name>

## Purpose

Briefly describe the action's goal.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **Param1** (`type`): Description.

### Optional

- **Param2** (`type`): Description.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName <action-name> -ArgsJson '{
  "Param1": "value"
}'
```

## GitHub Action example

```yaml
- name: <action description>
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: <action-name>
    args_json: >-
      {
        "Param1": "value"
      }
```

## Return Codes

- `0` – success
- non‑zero – failure

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

Source: [scripts/<action-name>/](../../scripts/<action-name>/)
