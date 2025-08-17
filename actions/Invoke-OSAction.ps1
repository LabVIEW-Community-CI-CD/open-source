#requires -Version 7.0
param(
  [Parameter(Position=0)] [string] $ActionName,
  [Parameter()] [string] $ArgsJson = '{}',
  [Parameter()] [hashtable] $ArgsYaml,
  [Parameter()] [string] $ArgsFile,
  [Parameter()] [string] $WorkingDirectory,
  [Parameter()] [ValidateSet('ERROR','WARN','INFO','DEBUG')] [string] $LogLevel = 'INFO',
  [switch] $DryRun,
  [switch] $ListActions,
  [string] $Describe
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'OpenSourceActions.psm1') -Force

# Attempt to build registry from generated dispatcher metadata; fall back to
# a static map only if loading fails or produces no entries.
$FallbackRegistry = [ordered]@{
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
    'run-pester-tests'         = 'InvokeRunPesterTests'
    'run-unit-tests'           = 'InvokeRunUnitTests'
    'set-development-mode'     = 'InvokeSetDevelopmentMode'
  }

$Registry = $null
$dispatcherPath = Join-Path $PSScriptRoot '..' 'dispatchers.json'
try {
  if (Test-Path $dispatcherPath) {
    $raw = Get-Content -Path $dispatcherPath -Raw | ConvertFrom-Json -AsHashtable
    $generated = [ordered]@{}
    foreach ($fn in $raw.Keys) {
      if ($fn -notlike 'Invoke*') { continue }
      $name = $fn -replace '^Invoke'
      $name = $name -creplace '([a-z0-9])([A-Z])', '$1-$2'
      $name = $name -creplace '([A-Z])([A-Z][a-z])', '$1-$2'
      $name = $name -ireplace 'Lab-VIEW', 'LabVIEW'
      $generated[$name.ToLowerInvariant()] = $fn
    }
    if ($generated.Count -gt 0) { $Registry = $generated }
  }
} catch {
  # Ignore errors and fall back to the static table
}
if (-not $Registry) { $Registry = $FallbackRegistry }

# Sets the verbosity for informational and verbose messages.
# Level: Desired log level (ERROR, WARN, INFO, DEBUG).
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

# Outputs the list of available actions.
function Show-List {
  Write-Output 'Available actions:'
  $Registry.Keys | Sort-Object | ForEach-Object { Write-Output " - $_" }
}

# Displays parameter information for an action.
# Name: Action name to describe.
function Show-Description([string]$Name) {
  $key = $Name.ToLowerInvariant()
  if (-not $Registry.Contains($key)) { throw "Unknown action '$Name'" }
  $funcName = $Registry[$key]
  $cmd = Get-Command $funcName -ErrorAction Stop

  $consoleLines = @("$key parameters:")
  foreach ($p in $cmd.Parameters.Values) {
    $consoleLines += " - $($p.Name): $($p.ParameterType.Name)"
  }

  $consoleLines | ForEach-Object { Write-Output $_ }
}

# Filters a set of input arguments to those accepted by a dispatcher.
# InputArgs: Hashtable of supplied arguments.
# FuncName: Target dispatcher function name.
# ActionNameForWarn: Action name used when emitting warnings.
# ReturnUnknownParams: If set, returns unknown parameters as well.
function Filter-Args([hashtable]$InputArgs, [string]$FuncName, [string]$ActionNameForWarn, [switch]$ReturnUnknownParams) {
  $cmd = Get-Command $FuncName -ErrorAction Stop

  # Map each alias to its canonical parameter name for the target function
  $aliasMap = @{}
  foreach ($p in $cmd.Parameters.Values) {
    foreach ($a in $p.Aliases) { $aliasMap[$a] = $p.Name }
  }

  $unknown = @()
  $filtered = @{}
  foreach ($k in @($InputArgs.Keys)) {
    if ($cmd.Parameters.ContainsKey($k)) {
      $filtered[$k] = $InputArgs[$k]
    }
    elseif ($aliasMap.ContainsKey($k)) {
      $canonical = $aliasMap[$k]
      if (-not $filtered.ContainsKey($canonical)) { $filtered[$canonical] = $InputArgs[$k] }
    }
    else {
      $unknown += $k
    }
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

  # Parse ArgsFile/ArgsJson/ArgsYaml → case-insensitive hashtable
  $argsHash = @{}
  if ($ArgsFile) {
    if (-not (Test-Path $ArgsFile)) { throw "ArgsFile '$ArgsFile' not found" }
    $ext = [System.IO.Path]::GetExtension($ArgsFile).ToLowerInvariant()
    $content = Get-Content -Path $ArgsFile -Raw
    try {
      switch ($ext) {
        '.json' {
          $fileArgs = ConvertFrom-Json -InputObject $content -AsHashtable -ErrorAction Stop
        }
        '.yaml' {
          $fileArgs = ConvertFrom-Yaml -Yaml $content -ErrorAction Stop | ConvertTo-Json -Depth 32 | ConvertFrom-Json -AsHashtable
        }
        '.yml' {
          $fileArgs = ConvertFrom-Yaml -Yaml $content -ErrorAction Stop | ConvertTo-Json -Depth 32 | ConvertFrom-Json -AsHashtable
        }
        default {
          throw "Unsupported ArgsFile extension '$ext'. Use .json, .yaml, or .yml."
        }
      }
    }
    catch {
      throw "ArgsFile could not be parsed: $($_.Exception.Message)"
    }
    foreach ($k in $fileArgs.Keys) { $argsHash[$k] = $fileArgs[$k] }
  }

  if ($ArgsJson -and $ArgsJson.Trim()) {
    try {
      $jsonHash = ConvertFrom-Json -InputObject $ArgsJson -AsHashtable -ErrorAction Stop
    }
    catch {
      # If parsing fails (commonly due to unescaped Windows backslashes),
      # attempt to escape all single backslashes and parse again. This allows
      # callers to provide paths like C:\repo without manually double-escaping
      # each separator.
        $escapedJson = $ArgsJson.Replace('\', '\\')
      try {
        $jsonHash = ConvertFrom-Json -InputObject $escapedJson -AsHashtable -ErrorAction Stop
        Write-Warning 'ArgsJson contained unescaped backslashes. They were automatically escaped.'
      }
      catch {
        throw "ArgsJson is not valid JSON: $($_.Exception.Message)"
      }
    }
    foreach ($k in $jsonHash.Keys) { $argsHash[$k] = $jsonHash[$k] }
  }
  if ($ArgsYaml) {
    foreach ($k in $ArgsYaml.Keys) {
      $argsHash[$k] = $ArgsYaml[$k]
    }
  }

  if ($DryRun) { $argsHash['DryRun'] = $true }

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
