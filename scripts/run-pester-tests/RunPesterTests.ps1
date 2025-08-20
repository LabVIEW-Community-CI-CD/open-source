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
$testPath = Join-Path (Resolve-Path $WorkingDirectory) 'tests/pester'
Push-Location $WorkingDirectory
$cfg = New-PesterConfiguration
if ($cfg.Output.PSObject.Properties.Name -contains 'NoColor') {
    $cfg.Output.NoColor = $true
}
$cfg.Run.Path = $testPath
$cfg.TestResult.Enabled = $true
$cfg.TestResult.OutputFormat = 'JUnitXml'
$timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$artifactDir = Join-Path $WorkingDirectory "artifacts/pester-junit-$timestamp"
New-Item -ItemType Directory -Path $artifactDir -Force | Out-Null
$cfg.TestResult.OutputPath = Join-Path $artifactDir 'pester-junit.xml'
$env:PESTER_JUNIT_PATH = $artifactDir

$run = Invoke-Pester -Configuration $cfg
$exitCode = $LASTEXITCODE

$coverage = @{}
foreach ($test in $run.TestResult) {
    foreach ($tag in $test.Tags) {
        if (-not $coverage.ContainsKey($tag)) { $coverage[$tag] = 'PASS' }
        if ($test.Result -ne 'Passed') { $coverage[$tag] = 'FAIL' }
    }
}

$requirementsPath = Join-Path $WorkingDirectory 'requirements.json'
if (Test-Path $requirementsPath) {
    $requirements = (Get-Content $requirementsPath | ConvertFrom-Json).requirements
    $report = foreach ($req in $requirements) {
        $status = if ($coverage.ContainsKey($req.id)) { $coverage[$req.id] } else { 'NOT_RUN' }
        [pscustomobject]@{ id = $req.id; status = $status }
    }
    $reportPath = Join-Path $WorkingDirectory 'requirement-coverage.json'
    $report | ConvertTo-Json -Depth 5 | Set-Content -Path $reportPath
}

Pop-Location
exit $exitCode

