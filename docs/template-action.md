# Action Documentation Template

This template standardizes action and workflow documentation.

## Purpose

Explain what the action or workflow does.

## Parameters

Describe required and optional parameters.

### Required

- **ParameterName** (`type`): Description of required parameter.

### Optional

- **ParameterName** (`type`): Description of optional parameter.

### GitHub Action inputs

Map GitHub Action inputs to CLI parameters when applicable.

| Input | CLI parameter | Description |
| --- | --- | --- |
| `input_name` | `ParameterName` | Explanation. |

## Examples

### CLI

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName <action-name> -ArgsJson '{
  "ParameterName": "value"
}'
```

### GitHub Action

```yaml
- name: Run action
  uses: owner/repo/<action-name>@v1
  with:
    input_name: value
```

## Return Codes

- `0` – success
- non‑zero – failure
