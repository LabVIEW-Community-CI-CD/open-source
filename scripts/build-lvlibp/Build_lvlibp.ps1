<#
.SYNOPSIS
    Builds the Editor Packed Library (.lvlibp) using g-cli.

.DESCRIPTION
    Invokes the LabVIEW build specification "Editor Packed Library" through
    g-cli, embedding the provided version information and commit identifier.

.PARAMETER MinimumSupportedLVVersion
    LabVIEW version used for the build.

.PARAMETER SupportedBitness
    Bitness of the LabVIEW environment ("32" or "64").

.PARAMETER RelativePath
    Path relative to the action's working directory. Use "." for the working directory (e.g., repository root).

.PARAMETER Major
    Major version component for the PPL.

.PARAMETER Minor
    Minor version component for the PPL.

.PARAMETER Patch
    Patch version component for the PPL.

.PARAMETER Build
    Build number component for the PPL.

.PARAMETER Commit
    Commit hash or identifier recorded in the build.

.EXAMPLE
    .\Build_lvlibp.ps1 -MinimumSupportedLVVersion "2021" -SupportedBitness "64" -RelativePath "." -Major 1 -Minor 0 -Patch 0 -Build 0 -Commit "Placeholder"
#>
param(
    [string]$MinimumSupportedLVVersion,
    [string]$SupportedBitness,
    [string]$RelativePath,
    [Int32]$Major,
    [Int32]$Minor,
    [Int32]$Patch,
    [Int32]$Build,
    [string]$Commit
)

Write-Output "PPL Version: $Major.$Minor.$Patch.$Build"
Write-Output "Commit: $Commit"

# Construct the command
$script = @"
g-cli --lv-ver $MinimumSupportedLVVersion --arch $SupportedBitness lvbuildspec -- -v "$Major.$Minor.$Patch.$Build" -p "$RelativePath\lv_icon_editor.lvproj" -b "Editor Packed Library"
"@
Write-Output "Executing the following command:"
Write-Output $script

# Execute the command
Invoke-Expression $script

# Check the exit code
if ($LASTEXITCODE -ne 0) {
    g-cli --lv-ver $MinimumSupportedLVVersion --arch $SupportedBitness QuitLabVIEW
    Write-Host "Build failed with exit code $LASTEXITCODE."
    exit 1
} else {
    Write-Host "Build succeeded."
    exit 0
}

