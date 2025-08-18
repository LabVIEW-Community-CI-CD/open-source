<#
.SYNOPSIS
    Runs MissingInProjectCLI.vi via G‑CLI and streams the VI’s output.

.PARAMETER LVVersion
    LabVIEW version (e.g. "2021").

.PARAMETER Arch
    Bitness ("32" or "64").

.PARAMETER ProjectFile
    Full path to the .lvproj that should be inspected.

.NOTES
    • Leaves exit status in $LASTEXITCODE for the caller.
    • Does NOT call 'exit' to avoid terminating a parent session.
#>
#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$LVVersion,
    [Parameter(Mandatory)][ValidateSet('32','64')][string]$Arch,
    [Parameter(Mandatory)][string]$ProjectFile
)
$ErrorActionPreference = 'Stop'
Write-Host "ℹ️  [GCLI] Starting Missing‑in‑Project check ..."

# ---------- sanity checks ----------
if (-not (Get-Command g-cli -ErrorAction SilentlyContinue)) {
    Write-Host "❌  g-cli executable not found in PATH."
    $global:LASTEXITCODE = 127
    return
}

$viPath = Join-Path -Path $PSScriptRoot -ChildPath 'MissingInProjectCLI.vi'
if (-not (Test-Path $viPath)) {
    Write-Host "❌  VI not found: $viPath"
    $global:LASTEXITCODE = 2
    return
}
if (-not (Test-Path $ProjectFile)) {
    Write-Host "❌  Project file not found: $ProjectFile"
    $global:LASTEXITCODE = 3
    return
}

Write-Host "ℹ️  VI path      : $viPath"
Write-Host "ℹ️  Project file : $ProjectFile"
Write-Host "ℹ️  LabVIEW ver  : $LVVersion  ($Arch-bit)"
Write-Host "--------------------------------------------------"

# ---------- build argument list & invoke ----------
$gcliArgs = @(
    '--lv-ver', $LVVersion,
    '--arch',   $Arch,
    $viPath,
    '--',
    $ProjectFile
)

$gcliOutput = & g-cli @gcliArgs 2>&1 | Tee-Object -Variable _outLines
$exitCode   = $LASTEXITCODE

# relay all output so the wrapper can capture & parse
$gcliOutput | ForEach-Object { Write-Output $_ }

if ($exitCode -eq 0) {
    Write-Host "✅  Missing‑in‑Project check passed (no missing files)."
} else {
    Write-Host "❌  Missing‑in‑Project check FAILED – exit code $exitCode"
}

# close LabVIEW if still running (harmless if not)
& g-cli --lv-ver $LVVersion --arch $Arch QuitLabVIEW | Out-Null

$global:LASTEXITCODE = $exitCode
return
