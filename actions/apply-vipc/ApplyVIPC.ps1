param(
    [string]$MinimumSupportedLVVersion,
    [string]$VIP_LVVersion,
    [string]$SupportedBitness,
    [string]$RelativePath,
    [string]$VIPCPath
)
$script = [System.IO.Path]::Combine($PSScriptRoot, '..', '..', 'scripts', 'apply-vipc', 'ApplyVIPC.ps1')
& $script @PSBoundParameters
