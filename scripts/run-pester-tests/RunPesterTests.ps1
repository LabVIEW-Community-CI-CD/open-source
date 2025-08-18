<#
.SYNOPSIS
    Run Pester tests located in a repository.

.DESCRIPTION
    Invokes Pester against the tests under the provided working directory.

.PARAMETER WorkingDirectory
    Path to the repository containing tests under `tests/pester`.

.NOTES
    PowerShell 7.5+ assumed for cross-platform support.
#>

param(
    [Parameter(Mandatory=$true)]
    [string]
    $WorkingDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$testPath = Join-Path $WorkingDirectory 'tests/pester'
$cfg = New-PesterConfiguration
$cfg.Output.NoColor = $true
$cfg.Run.Path = $testPath
$cfg.TestResult.Enabled = $false
$ansiPattern = '\x1B\[[0-9;]*[A-Za-z]'

$output = & {
    Invoke-Pester -Configuration $cfg 2>&1
}
$exitCode = $LASTEXITCODE
$output | ForEach-Object { $_ -replace $ansiPattern, '' }
exit $exitCode

