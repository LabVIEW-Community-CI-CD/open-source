<#
.SYNOPSIS
    Configures the repository for development mode.

.DESCRIPTION
    Removes existing packed libraries, adds INI tokens, prepares LabVIEW
    sources for both 32-bit and 64-bit environments, and closes LabVIEW.

.PARAMETER RelativePath
    Path relative to the action's working directory. Use "." for the working directory (e.g., repository root).

.EXAMPLE
    .\Set_Development_Mode.ps1 -RelativePath "."
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$RelativePath
)

# Helper function to execute scripts and stop on error
function Execute-Script {
    param(
        [string]$ScriptCommand
    )
    Write-Host "Executing: $ScriptCommand"
    try {
        Invoke-Expression $ScriptCommand -ErrorAction Stop
    } catch {
        throw "Error occurred while executing: $ScriptCommand"
    }
}
# Sequential script execution with error handling
try {
	Execute-Script "Get-ChildItem -Path '$RelativePath\resource\plugins' -Filter '*.lvlibp' | Remove-Item -Force" 
    Execute-Script ".\AddTokenToLabVIEW.ps1 -MinimumSupportedLVVersion 2021 -SupportedBitness 32 -RelativePath '$RelativePath'"
    Execute-Script ".\Prepare_LabVIEW_source.ps1 -MinimumSupportedLVVersion 2021 -SupportedBitness 32 -RelativePath '$RelativePath' -LabVIEW_Project 'lv_icon_editor' -Build_Spec 'Editor Packed Library'" 
    Execute-Script ".\Close_LabVIEW.ps1 -MinimumSupportedLVVersion 2021 -SupportedBitness 32" 
	Execute-Script ".\AddTokenToLabVIEW.ps1 -MinimumSupportedLVVersion 2021 -SupportedBitness 64 -RelativePath '$RelativePath'" 
    Execute-Script ".\Prepare_LabVIEW_source.ps1 -MinimumSupportedLVVersion 2021 -SupportedBitness 64 -RelativePath '$RelativePath' -LabVIEW_Project 'lv_icon_editor' -Build_Spec 'Editor Packed Library'" 
    Execute-Script ".\Close_LabVIEW.ps1 -MinimumSupportedLVVersion 2021 -SupportedBitness 64" 

} catch {
    Write-Error "An unexpected error occurred during script execution: $($_.Exception.Message)"
    exit 1
}

Write-Host "All scripts executed successfully."

