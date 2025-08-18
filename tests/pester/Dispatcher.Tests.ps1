#requires -Version 7.0
# Pester v5+ tests that do NOT require LabVIEW/g-cli.
# Run:
#   $cfg = New-PesterConfiguration
#   $cfg.Run.Path = './tests/pester'
#   $cfg.TestResult.Enabled = $false
#   Invoke-Pester -Configuration $cfg
# Requirement: REQ-001 - Dispatcher discovers available actions, describes them, and validates arguments.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$global:dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

$meta = @{
    requirement = 'REQ-001'
    Owner       = 'DevTools'
    Evidence    = 'tests/pester/Dispatcher.Tests.ps1'
}

Describe 'Unified Dispatcher — discovery and validation' {
  It 'lists available actions' -Tag 'REQ-001' {
    $params = Get-LabVIEWIconEditorArgsJson
    $json = $params.ArgsJson
    $projectRoot = $params.WorkingDirectory
    $out = pwsh -NoProfile -File $global:dispatcher -ListActions -ArgsJson $json -WorkingDirectory $projectRoot | Out-String
    $out | Should -Match 'apply-vipc'
    $out | Should -Match 'build-lvlibp'
    $out | Should -Match 'missing-in-project'
    $out | Should -Match 'run-unit-tests'
  }
  It 'registry includes all Invoke* adapters in module' -Tag 'REQ-001' {
    $modulePath = Join-Path (Split-Path $global:dispatcher -Parent) 'OpenSourceActions.psm1'
    $module = Import-Module $modulePath -PassThru
    $fnNames = (Get-Command -Module $module | Where-Object Name -like 'Invoke*').Name
    function Convert-Name([string]$fn) {
      $name = $fn -replace '^Invoke'
      $name = $name -creplace '([a-z0-9])([A-Z])', '$1-$2'
      $name = $name -creplace '([A-Z])([A-Z][a-z])', '$1-$2'
      $name = $name -ireplace 'Lab-VIEW', 'LabVIEW'
      return $name.ToLowerInvariant()
    }
    $expected = $fnNames | ForEach-Object { Convert-Name $_ }
    $wd = (Get-LabVIEWIconEditorArgsJson).WorkingDirectory
    $listed = pwsh -NoProfile -File $global:dispatcher -ListActions -WorkingDirectory $wd | Out-String
    foreach ($action in $expected) {
      $listed | Should -Match " - $action"
    }
  }
  It 'describes a known action (build-lvlibp)' -Tag 'REQ-001' {
    $params = Get-LabVIEWIconEditorArgsJson
    $json = $params.ArgsJson
    $projectRoot = $params.WorkingDirectory
    $out = pwsh -NoProfile -File $global:dispatcher -Describe build-lvlibp -ArgsJson $json -WorkingDirectory $projectRoot | Out-String
    $out | Should -Match 'Major'
    $out | Should -Match 'Minor'
    $out | Should -Match 'Patch'
    $out | Should -Match 'Build'
    $out | Should -Match 'Commit'
  }

  It 'fails gracefully on unknown action' -Tag 'REQ-001' {
    $params = Get-LabVIEWIconEditorArgsJson
    $json = $params.ArgsJson
    $projectRoot = $params.WorkingDirectory
    pwsh -NoProfile -File $global:dispatcher -ActionName no-such-action -ArgsJson $json -WorkingDirectory $projectRoot *>$null
    $LASTEXITCODE | Should -Be 1
  }
}

Describe 'ArgsJson path handling' {
  It 'handles Windows paths without manual escaping' -Tag 'REQ-001' {
    $params = Get-LabVIEWIconEditorArgsJson
    $json = $params.ArgsJson
    $projectRoot = $params.WorkingDirectory
    & $global:dispatcher -ActionName set-development-mode -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *> $null
    $LASTEXITCODE | Should -Be 0
  }
}

Describe 'ArgsFile handling' {
  It 'merges file arguments with inline overrides' -Tag 'REQ-001' {
    $jsonFile = Join-Path $TestDrive 'args.json'
    @{ MinimumSupportedLVVersion = '2021'; SupportedBitness = '32' } | ConvertTo-Json -Compress | Set-Content -Path $jsonFile

    $overrideJson = @{ SupportedBitness = '64' } | ConvertTo-Json -Compress

    $projectRoot = (Get-LabVIEWIconEditorArgsJson).WorkingDirectory
    $out = & $global:dispatcher -ActionName close-labview -ArgsFile $jsonFile -ArgsJson $overrideJson -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
    $LASTEXITCODE | Should -Be 0
    $out | Should -Match '"SupportedBitness":"64"'
  }
}


Describe 'Filter-Args helper' {
  It 'returns UnknownParams when requested' -Tag 'REQ-001' {
    $ast = [System.Management.Automation.Language.Parser]::ParseFile($global:dispatcher, [ref]$null, [ref]$null)
    $funcAst = $ast.Find({ param($a) $a -is [System.Management.Automation.Language.FunctionDefinitionAst] -and $a.Name -eq 'Filter-Args' }, $true)
    Invoke-Expression $funcAst.Extent.Text

    function Dummy { param([string]$Known) }
    $args = @{ Known = 'value'; Extra = 'x' }
    $result = Filter-Args -InputArgs $args -FuncName 'Dummy' -ActionNameForWarn 'dummy' -ReturnUnknownParams
    $result.PSObject.Properties.Name | Should -Contain 'UnknownParams'
  }
}

  Describe 'close-labview parameter aliases' {
    It 'accepts camelCase args' -Tag 'REQ-001' {
      $params = Get-LabVIEWIconEditorArgsJson
      $base = $params.ArgsJson | ConvertFrom-Json
      $projectRoot = $params.WorkingDirectory
      $json = @{
        MinimumSupportedLVVersion = $base.MinimumSupportedLVVersion
        SupportedBitness = $base.SupportedBitness
      } | ConvertTo-Json -Compress
      & $global:dispatcher -ActionName close-labview -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *> $null
      $LASTEXITCODE | Should -Be 0
    }

    It 'accepts snake_case args without warnings' -Tag 'REQ-001' {
      $params = Get-LabVIEWIconEditorArgsJson
      $base = $params.ArgsJson | ConvertFrom-Json
      $projectRoot = $params.WorkingDirectory
      $json = @{
        minimum_supported_lv_version = $base.MinimumSupportedLVVersion
        supported_bitness = $base.SupportedBitness
      } | ConvertTo-Json -Compress
      $out = & $global:dispatcher -ActionName close-labview -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
      $LASTEXITCODE | Should -Be 0
      $out | Should -Not -Match 'Ignored unknown parameters'
      $out | Should -Not -Match 'Missing an argument'
    }
  }
