function Get-LabVIEWIconEditorArgsJson {
    [OutputType([pscustomobject])]
    param(
        [switch]$RequireProject
    )

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..' '..')).Path

    $require = $RequireProject -or [bool]$env:LABVIEW_ICON_EDITOR_REQUIRED

    if ($env:LABVIEW_ICON_EDITOR_PATH) {
        $workingDir = $env:LABVIEW_ICON_EDITOR_PATH
        $require = $true
    } elseif ($require) {
        $workingDir = Join-Path $repoRoot 'labview-icon-editor'
    } else {
        $workingDir = $repoRoot
    }

    if ($require -and -not (Test-Path -Path $workingDir)) {
        throw 'labview-icon-editor repository not found. Clone https://github.com/LabVIEW-Community-CI-CD/labview-icon-editor or set LABVIEW_ICON_EDITOR_PATH to its location.'
    }

    $args = @{
        MinimumSupportedLVVersion = '2021'
        SupportedBitness          = '64'
        RelativePath              = '.'
    }

    return [pscustomobject]@{
        ArgsJson         = ($args | ConvertTo-Json -Compress)
        WorkingDirectory = $workingDir
    }
}

Export-ModuleMember -Function Get-LabVIEWIconEditorArgsJson
