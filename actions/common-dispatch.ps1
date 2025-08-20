#requires -Version 7.0
param(
  [Parameter(Mandatory)] [string] $ActionName,
  [Parameter()] [hashtable] $Args = @{},
  [Parameter()] [ValidateSet('ERROR','WARN','INFO','DEBUG')] [string] $LogLevel = 'INFO',
  [switch] $DryRun,
  [string] $WorkingDirectory
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$invokeParams = @{
  ActionName    = $ActionName
  ArgsHashtable = $Args
  LogLevel      = $LogLevel
}
if ($DryRun)        { $invokeParams['DryRun'] = $true }
if ($WorkingDirectory) { $invokeParams['WorkingDirectory'] = $WorkingDirectory }

$script = Join-Path $PSScriptRoot 'Invoke-OSAction.ps1'
& $script @invokeParams
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
