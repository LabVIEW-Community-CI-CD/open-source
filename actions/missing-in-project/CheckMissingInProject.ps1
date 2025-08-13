param(
    [string]$LVVersion,
    [string]$Arch,
    [string]$ProjectFile
)
$script = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', 'scripts', 'missing-in-project', 'Invoke-MissingInProjectCLI.ps1')
& $script @PSBoundParameters
