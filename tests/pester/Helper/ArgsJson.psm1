function Get-LabVIEWIconEditorArgsJson {
    [OutputType([string])]
    param()

    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
    if ($env:LABVIEW_ICON_EDITOR_PATH) {
        $relativePath = $env:LABVIEW_ICON_EDITOR_PATH
    } elseif ($IsWindows) {
        $relativePath = Join-Path $repoRoot 'labview-icon-editor'
    } elseif ($IsLinux) {
        $relativePath = Join-Path $repoRoot 'labview-icon-editor'
    } elseif ($IsMacOS) {
        $relativePath = Join-Path $repoRoot 'labview-icon-editor'
    } else {
        throw 'Unsupported platform'
    }

    $args = @{
        MinimumSupportedLVVersion = '2021'
        SupportedBitness          = '64'
        RelativePath              = $relativePath
    }

    return ($args | ConvertTo-Json -Compress)
}

Export-ModuleMember -Function Get-LabVIEWIconEditorArgsJson
