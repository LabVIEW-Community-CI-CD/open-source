# `<action-name>`

## Purpose

Briefly describe the action's goal.

## Parameters

Common parameters are described in [Common parameters](../docs/common-parameters.md).

### Required

- **Param1** (`type`): Description.

### Optional

- **Param2** (`type`): Description.

> **Unknown parameters:** Parameters not recognized by the dispatcher are ignored with a warning. The warning message can be retrieved from the returned object's `UnknownParams` field when requested.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName <action-name> -ArgsJson '{
  "Param1": "value"
}'
```

## GitHub Action example

```yaml
- name: <action description>
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
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

For troubleshooting tips, see the [troubleshooting guide](../docs/troubleshooting.md).

Source: [scripts/`<action-name>`/](../../scripts/<action-name>/) <!-- markdown-link-check-disable-line -->
