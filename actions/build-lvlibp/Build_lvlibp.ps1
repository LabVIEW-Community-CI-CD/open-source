param(
    [string]$MinimumSupportedLVVersion,
    [string]$SupportedBitness,
    [string]$RelativePath,
    [string]$LabVIEW_Project,
    [string]$Build_Spec,
    [int]$Major,
    [int]$Minor,
    [int]$Patch,
    [int]$Build,
    [string]$Commit
)
$script = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', 'scripts', 'build-lvlibp', 'Build_lvlibp.ps1')
& $script @PSBoundParameters
