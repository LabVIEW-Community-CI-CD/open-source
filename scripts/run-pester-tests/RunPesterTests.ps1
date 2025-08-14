<#
.SYNOPSIS
    Run Pester tests and output a color-coded table of results.

.DESCRIPTION
    Invokes Pester tests located under tests/pester and prints a table of
    Describe, Name, Result, Duration, and Data for each test. The table uses
    green/yellow/red coloring for pass/skip/fail and exits with 2 if any test
    fails, otherwise 0.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$pesterDir = Join-Path $repoRoot 'tests' 'pester'

# Run Pester and capture results
$pesterResult = Invoke-Pester -Path $pesterDir -PassThru
$tests = if ($pesterResult.Tests) { $pesterResult.Tests } else { $pesterResult.TestResult }

$col1 = 'Describe'; $col2 = 'Name'; $col3 = 'Result'; $col4 = 'Duration'; $col5 = 'Data'
$max1 = $col1.Length; $max2 = $col2.Length; $max3 = $col3.Length; $max4 = $col4.Length; $max5 = $col5.Length
$rows = @()
$hadFail = $false

foreach ($t in $tests) {
    $describe = $t.Describe
    $name     = $t.Name
    $result   = $t.Result
    $duration = '{0:N3}' -f $t.Duration.TotalSeconds
    $data     = if ($null -ne $t.Data) { $t.Data | ConvertTo-Json -Compress } else { '' }

    if ($describe.Length -gt $max1) { $max1 = $describe.Length }
    if ($name.Length     -gt $max2) { $max2 = $name.Length }
    if ($result.Length   -gt $max3) { $max3 = $result.Length }
    if ($duration.Length -gt $max4) { $max4 = $duration.Length }
    if ($data.Length     -gt $max5) { $max5 = $data.Length }

    $rows += [pscustomobject]@{
        Describe = $describe
        Name     = $name
        Result   = $result
        Duration = $duration
        Data     = $data
    }

    if ($result -ne 'Passed' -and $result -ne 'Skipped') { $hadFail = $true }
}

$header = ($col1.PadRight($max1) + '  ' +
           $col2.PadRight($max2) + '  ' +
           $col3.PadRight($max3) + '  ' +
           $col4.PadRight($max4) + '  ' +
           $col5.PadRight($max5))
Write-Host $header

foreach ($row in $rows) {
    $line = ($row.Describe.PadRight($max1) + '  ' +
             $row.Name.PadRight($max2)     + '  ' +
             $row.Result.PadRight($max3)   + '  ' +
             $row.Duration.PadRight($max4) + '  ' +
             $row.Data.PadRight($max5))
    switch ($row.Result) {
        'Passed'  { Write-Host $line -ForegroundColor Green }
        'Skipped' { Write-Host $line -ForegroundColor Yellow }
        default   { Write-Host $line -ForegroundColor Red }
    }
}

if ($hadFail) { exit 2 } else { exit 0 }
