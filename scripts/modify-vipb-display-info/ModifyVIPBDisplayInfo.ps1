<#
.SYNOPSIS
    Updates display information in a VIPB file and rebuilds the VI package.

.DESCRIPTION
    Resolves paths, merges version data into the DisplayInformation JSON, and
    calls g-cli to update and build the package defined by the VIPB file.

.PARAMETER SupportedBitness
    LabVIEW bitness for the build ("32" or "64").

.PARAMETER RelativePath
    Path relative to the action's working directory. Use "." for the working directory (e.g., repository root).

.PARAMETER VIPBPath
    Relative path to the VIPB file to modify.

.PARAMETER MinimumSupportedLVVersion
    Minimum LabVIEW version supported by the package.

.PARAMETER LabVIEWMinorRevision
    Minor revision number of LabVIEW (0 or 3).

.PARAMETER Major
    Major version component for the package.

.PARAMETER Minor
    Minor version component for the package.

.PARAMETER Patch
    Patch version component for the package.

.PARAMETER Build
    Build number component for the package.

.PARAMETER Commit
    Commit identifier embedded in the package metadata.

.PARAMETER ReleaseNotesFile
    Path to a release notes file injected into the build.

.PARAMETER DisplayInformationJSON
    JSON string representing the VIPB display information to update.

.EXAMPLE
    .\ModifyVIPBDisplayInfo.ps1 -SupportedBitness "64" -RelativePath "." -VIPBPath "Tooling\deployment\NI Icon editor.vipb" -MinimumSupportedLVVersion 2023 -LabVIEWMinorRevision 3 -Major 1 -Minor 0 -Patch 0 -Build 2 -Commit "abcd123" -ReleaseNotesFile "Tooling\deployment\release_notes.md" -DisplayInformationJSON '{"Package Version":{"major":1,"minor":0,"patch":0,"build":2}}'
#>
param (
    [string]$SupportedBitness,
    [string]$RelativePath,
    [string]$VIPBPath,

    [int]$MinimumSupportedLVVersion,

    [ValidateSet("0","3")]
    [string]$LabVIEWMinorRevision = "0",

    [int]$Major,
    [int]$Minor,
    [int]$Patch,
    [int]$Build,
    [string]$Commit,
    [string]$ReleaseNotesFile,

    [Parameter(Mandatory=$true)]
    [string]$DisplayInformationJSON
)

# 1) Resolve paths
try {
    $ResolvedRelativePath = Resolve-Path -Path $RelativePath -ErrorAction Stop
    $ResolvedVIPBPath = Join-Path -Path $ResolvedRelativePath -ChildPath $VIPBPath -ErrorAction Stop
}
catch {
    $errorObject = [PSCustomObject]@{
        error      = "Error resolving paths. Ensure RelativePath and VIPBPath are valid."
        exception  = $_.Exception.Message
        stackTrace = $_.Exception.StackTrace
    }
    $errorObject | ConvertTo-Json -Depth 10
    exit 1
}

# 2) Create release notes if needed
if (-not (Test-Path $ReleaseNotesFile)) {
    Write-Host "Release notes file '$ReleaseNotesFile' does not exist. Creating it..."
    New-Item -ItemType File -Path $ReleaseNotesFile -Force | Out-Null
}

# 3) Calculate the LabVIEW version string
$lvNumericMajor    = $MinimumSupportedLVVersion - 2000
$lvNumericVersion  = "$($lvNumericMajor).$LabVIEWMinorRevision"
if ($SupportedBitness -eq "64") {
    $VIP_LVVersion_A = "$lvNumericVersion (64-bit)"
}
else {
    $VIP_LVVersion_A = $lvNumericVersion
}
Write-Output "Modifying VI Package Information using LabVIEW $VIP_LVVersion_A..."

# 4) Parse and update the DisplayInformationJSON
try {
    $jsonObj = $DisplayInformationJSON | ConvertFrom-Json
}
catch {
    $errorObject = [PSCustomObject]@{
        error      = "Failed to parse DisplayInformationJSON into valid JSON."
        exception  = $_.Exception.Message
        stackTrace = $_.Exception.StackTrace
    }
    $errorObject | ConvertTo-Json -Depth 10
    exit 1
}

# If "Package Version" doesn't exist, create it as a subobject
if (-not $jsonObj.'Package Version') {
    $jsonObj | Add-Member -MemberType NoteProperty -Name 'Package Version' -Value ([PSCustomObject]@{
        major = $Major
        minor = $Minor
        patch = $Patch
        build = $Build
    })
}
else {
    # "Package Version" exists, so just overwrite its fields
    $jsonObj.'Package Version'.major = $Major
    $jsonObj.'Package Version'.minor = $Minor
    $jsonObj.'Package Version'.patch = $Patch
    $jsonObj.'Package Version'.build = $Build
}

# Re-convert to a JSON string with a comfortable nesting depth
$UpdatedDisplayInformationJSON = $jsonObj | ConvertTo-Json -Depth 5

# 5) Prepare the g-cli command and arguments
$cmd  = "g-cli"
$args = @(
    '--lv-ver', $MinimumSupportedLVVersion,
    '--arch',   $SupportedBitness,
    "$ResolvedRelativePath\Tooling\deployment\Modify_VIPB_Display_Information.vi",
    '--',
    $ResolvedVIPBPath,
    $VIP_LVVersion_A,
    $UpdatedDisplayInformationJSON
)

Write-Output "Executing: $cmd $($args -join ' ')"

# 6) Execute the command safely
try {
    & $cmd @args
    Write-Host "Successfully Modified VI package information: $ResolvedVIPBPath"
}
catch {
    $errorObject = [PSCustomObject]@{
        error      = "An error occurred while executing the build commands."
        exception  = $_.Exception.Message
        stackTrace = $_.Exception.StackTrace
    }
    $errorObject | ConvertTo-Json -Depth 10
    exit 1
}
