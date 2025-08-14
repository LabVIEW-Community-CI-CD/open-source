#requires -Version 7.0
param(
  [Parameter(Position=0)] [string] $ActionName,
  [Parameter()] [string] $ArgsJson = '{}',
  [Parameter()] [string] $WorkingDirectory,
  [Parameter()] [ValidateSet('ERROR','WARN','INFO','DEBUG')] [string] $LogLevel = 'INFO',
  [switch] $DryRun,
  [switch] $ListActions,
  [string] $Describe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'OpenSourceActions.psm1') -Force

# Ordered registry of action name to adapter function
$Registry = [ordered]@{
    'add-token-to-labview'      = 'InvokeAddTokenToLabVIEW'
    'apply-vipc'               = 'InvokeApplyVIPC'
    'build'                    = 'InvokeBuild'
    'build-lvlibp'             = 'InvokeBuildLvlibp'
    'build-vi-package'         = 'InvokeBuildViPackage'
    'close-labview'            = 'InvokeCloseLabVIEW'
    'generate-release-notes'   = 'InvokeGenerateReleaseNotes'
    'missing-in-project'       = 'InvokeMissingInProject'
    'modify-vipb-display-info' = 'InvokeModifyVIPBDisplayInfo'
    'prepare-labview-source'   = 'InvokePrepareLabVIEWSource'
    'rename-file'              = 'InvokeRenameFile'
    'restore-setup-lv-source'  = 'InvokeRestoreSetupLVSource'
    'revert-development-mode'  = 'InvokeRevertDevelopmentMode'
    'run-unit-tests'           = 'InvokeRunUnitTests'
    'set-development-mode'     = 'InvokeSetDevelopmentMode'
}

function Set-LogLevel {
  param([string]$Level)
  switch ($Level.ToUpperInvariant()) {
    'ERROR' { $InformationPreference='SilentlyContinue'; $VerbosePreference='SilentlyContinue' }
    'WARN'  { $InformationPreference='SilentlyContinue'; $VerbosePreference='SilentlyContinue' }
    'INFO'  { $InformationPreference='Continue';         $VerbosePreference='SilentlyContinue' }
    'DEBUG' { $InformationPreference='Continue';         $VerbosePreference='Continue' }
    default { $InformationPreference='Continue';         $VerbosePreference='SilentlyContinue' }
  }
}

function Show-List {
  Write-Host 'Available actions:'
  $Registry.Keys | Sort-Object | ForEach-Object { Write-Host " - $_" }
}

function Show-Description([string]$Name) {
  $key = $Name.ToLowerInvariant()
  if (-not $Registry.Contains($key)) { throw "Unknown action '$Name'" }
  $funcName = $Registry[$key]
  $cmd = Get-Command $funcName -ErrorAction Stop
  Write-Host "$key parameters:"
  foreach ($p in $cmd.Parameters.Values) {
    Write-Host " - $($p.Name): $($p.ParameterType.Name)"
  }
}

function Filter-Args([hashtable]$InputArgs, [string]$FuncName, [string]$ActionNameForWarn, [switch]$ReturnUnknownParams) {
  $cmd = Get-Command $FuncName -ErrorAction Stop
  $paramNames = @()
  foreach ($p in $cmd.Parameters.Values) {
    $paramNames += $p.Name
    if ($p.Aliases) { $paramNames += $p.Aliases }
  }
  $unknown = @()
  $filtered = @{}
  foreach ($k in @($InputArgs.Keys)) {
    if ($paramNames -contains $k) { $filtered[$k] = $InputArgs[$k] } else { $unknown += $k }
  }
  $msg = $null
  if ($unknown.Count) {
    $msg = "Ignored unknown parameters for '$ActionNameForWarn': $($unknown -join ', ')"
    Write-Warning $msg
  }
  if ($ReturnUnknownParams) {
    return [pscustomobject]@{ Args = $filtered; UnknownParams = $msg }
  }
  return $filtered
}

try {
  # Discovery short-circuits
  if ($ListActions) { Show-List; exit 0 }
  if ($Describe)    { Show-Description -Name $Describe; exit 0 }

  if (-not $ActionName) { throw 'ActionName is required unless using -ListActions or -Describe' }
  $key = $ActionName.ToLowerInvariant()
  if (-not $Registry.Contains($key)) { throw "Unknown ActionName '$ActionName'. Use -ListActions to see options." }
  $funcName = $Registry[$key]

  # Parse ArgsJson → case-insensitive hashtable
  $argsHash = @{}
  if ($ArgsJson -and $ArgsJson.Trim()) {
    try {
      $argsHash = ConvertFrom-Json -InputObject $ArgsJson -AsHashtable -ErrorAction Stop
    }
    catch {
      # If parsing fails (commonly due to unescaped Windows backslashes),
      # attempt to escape all single backslashes and parse again. This allows
      # callers to provide paths like C:\repo without manually double-escaping
      # each separator.
        $escapedJson = $ArgsJson.Replace('\', '\\')
      try {
        $argsHash = ConvertFrom-Json -InputObject $escapedJson -AsHashtable -ErrorAction Stop
        Write-Warning 'ArgsJson contained unescaped backslashes. They were automatically escaped.'
      }
      catch {
        throw "ArgsJson is not valid JSON: $($_.Exception.Message)"
      }
    }
  }
  if ($DryRun)   { $argsHash['DryRun']   = $true }
  if ($LogLevel) { $argsHash['LogLevel'] = $LogLevel }

  Set-LogLevel -Level $LogLevel

  # Only pass parameters that the adapter actually accepts
  $argsHash = Filter-Args -InputArgs $argsHash -FuncName $funcName -ActionNameForWarn $key

  if ($WorkingDirectory) { Push-Location -Path $WorkingDirectory }
  try {
    $result = & $funcName @argsHash
    $exitCode = if ($result -is [int]) { [int]$result }
                elseif ($LASTEXITCODE -is [int]) { [int]$LASTEXITCODE }
                else { 0 }
  } catch {
    Write-Error $_.Exception.Message
    $exitCode = 1
  } finally {
    if ($WorkingDirectory) { Pop-Location }
  }
  exit $exitCode
}
catch {
  Write-Error $_.Exception.Message
  exit 1
}
