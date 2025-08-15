<#
.SYNOPSIS
    Restores the LabVIEW source setup from a packaged state.

.DESCRIPTION
    Calls RestoreSetupLVSource.vi via g-cli to unzip the LabVIEW Icon API and
    remove the Localhost.LibraryPaths token from the LabVIEW INI file.

.PARAMETER MinimumSupportedLVVersion
    LabVIEW version used to run g-cli.

.PARAMETER SupportedBitness
    Bitness of the LabVIEW environment ("32" or "64").

.PARAMETER RelativePath
    Path to the repository root.

.PARAMETER LabVIEW_Project
    Name of the LabVIEW project (without extension).

.PARAMETER Build_Spec
    Build specification name within the project.

.EXAMPLE
    .\RestoreSetupLVSource.ps1 -MinimumSupportedLVVersion "2021" -SupportedBitness "64" -RelativePath "C:\labview-icon-editor" -LabVIEW_Project "lv_icon_editor" -Build_Spec "Editor Packed Library"
#>
param(
    [string]$MinimumSupportedLVVersion,
    [string]$SupportedBitness,
    [string]$RelativePath,
    [string]$LabVIEW_Project,
    [string]$Build_Spec
)

# Construct the command
$script = @"
g-cli --lv-ver $MinimumSupportedLVVersion --arch $SupportedBitness -v "$RelativePath\Tooling\RestoreSetupLVSource.vi" -- "$RelativePath\$LabVIEW_Project.lvproj" "$Build_Spec"
"@

Write-Output "Executing the following command:"
Write-Output $script

# Execute the command and check for errors
try {
    Invoke-Expression $script

    # Check the exit code of the executed command
    $exitCode = $LASTEXITCODE
    if ($exitCode -ne 0) {
        Write-Error "g-cli exited with code $exitCode"
        exit $exitCode
    }

    Write-Host "Unzip vi.lib/LabVIEW Icon API from LabVIEW $MinimumSupportedLVVersion ($SupportedBitness-bit) and remove localhost.library path from ini file"
} catch {
    Write-Error "Failed to restore LabVIEW source: $_"
    exit 1
}
