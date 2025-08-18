<#
.SYNOPSIS
    Adds a custom library path token to the LabVIEW INI file.

.DESCRIPTION
    Uses g-cli to call Create_LV_INI_Token.vi, inserting the provided path into
    the LabVIEW INI file under the Localhost.LibraryPaths token. This enables
    LabVIEW to locate local project libraries during development or builds.

.PARAMETER MinimumSupportedLVVersion
    LabVIEW version used by g-cli (e.g., "2021").

.PARAMETER SupportedBitness
    Target bitness of the LabVIEW environment ("32" or "64").

.PARAMETER RelativePath
    Path relative to the action's working directory. Use "." for the working directory (e.g., repository root).

.EXAMPLE
    .\AddTokenToLabVIEW.ps1 -MinimumSupportedLVVersion "2021" -SupportedBitness "64" -RelativePath "."
#>

param(
    [string]$MinimumSupportedLVVersion,
    [string]$SupportedBitness,
    [string]$RelativePath
)

# Build the g-cli argument array
$gcliArgs = @(
    '--lv-ver', $MinimumSupportedLVVersion,
    '--arch', $SupportedBitness,
    '-v', "$RelativePath\Tooling\deployment\Create_LV_INI_Token.vi",
    '--', 'LabVIEW', 'Localhost.LibraryPaths', $RelativePath
)

Write-Output "Executing: g-cli $($gcliArgs -join ' ')"

& g-cli @gcliArgs
if ($LASTEXITCODE -eq 0) {
    Write-Host 'Create localhost.library path from ini file'
} else {
    Write-Error 'Failed to add localhost.library path to INI file'
}
return $LASTEXITCODE
