# Adapter Authoring Guide

*For contributors who want to add new actions (adapters) or modify existing ones in the Open-Source Actions project.*

This guide explains the structure of the unified dispatcher and how to extend it with new adapters and scripts.

## Architecture Recap

- **Dispatcher Script (`Invoke-OSAction.ps1`)**: Entry point that parses inputs and dispatches to an adapter based on `-ActionName`.
- **PowerShell Module (`OpenSourceActions.psm1`)**: Houses all adapter functions and shared logic.
- **Underlying Scripts**: Implement the actual functionality and live under `scripts/<action-name>/`.

## Naming Conventions

- **Action Name**: Lowercase with hyphens, e.g., `"my-new-action"`.
- **Script Filename**: Place your PowerShell script in `scripts/<action-name>/` with a clear name.
- **Adapter Function Name**: Use `Invoke-<PascalCase>` (e.g., `Invoke-MyNewAction`).
- **Folder Structure**:

```text
scripts/
  my-new-action/
    MyNewAction.ps1
```

## Adapter Function Template

Add your function to `OpenSourceActions.psm1`:

```powershell
function Invoke-MyNewAction {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $Param1,
        [Parameter(Mandatory)] [int] $Param2,
        [Parameter()] [string] $OptionalParam = "default",
        [switch] $DryRun
    )
    Write-Information "Invoking MyNewAction with Param1=$Param1 ..." -InformationAction Continue
    $scriptPath = Join-Path $PSScriptRoot '../scripts/my-new-action/MyNewAction.ps1'
    $args = @{
        Param1 = $Param1
        Param2 = $Param2
        OptionalParam = $OptionalParam
    }
    if ($DryRun) {
        Write-Information "DryRun: would call $scriptPath with args $($args | ConvertTo-Json -Compress)"
        return 0
    }
    & $scriptPath @args
    if ($LASTEXITCODE -ne 0) {
        throw "MyNewAction failed with exit code $LASTEXITCODE"
    }
    return $LASTEXITCODE
}
```

## Registry Update (`dispatchers.json`)

After adding your adapter function, regenerate the dispatcher registry:

1. Run `npm run derive:registry` to update `dispatchers.json`.
2. Commit the regenerated file.

## Logging and Verbosity

Use `Write-Information` for normal logs and `Write-Verbose` for debug details. The dispatcher’s `-LogLevel` parameter sets verbosity before your adapter runs.

## DryRun Considerations

If `-DryRun` is specified, log what would happen and return 0 instead of calling the underlying script.

## Testing Your Adapter

- Add Pester tests in `tests/pester/`.
- Mock underlying script calls and verify mandatory parameter enforcement.
- Run `pwsh -File tests/pester/Dispatcher.Tests.ps1` before submitting.

## Module Version and Documentation

- Bump the module version in `OpenSourceActions.psd1` if appropriate.
- Document the new action under `docs/actions/`. Start from `_template.md` and include sections: Purpose, Parameters (Required/Optional), CLI example, GitHub Action example, and Return Codes. Update central lists.

## Logging and Error Handling Guidelines

- Avoid `Write-Host`.
- Throw on failure instead of using `Exit`.
- Clean up any temporary state your adapter creates.

## Following these Steps

By adhering to these conventions, your new action will be discoverable, consistent, and easier to maintain. Happy coding!
