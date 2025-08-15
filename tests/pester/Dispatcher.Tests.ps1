#requires -Version 7.0
# Pester v5+ tests that do NOT require LabVIEW/g-cli.
# Run:  Invoke-Pester -CI -Path ./tests/pester
# Requirement: REQ-001 - Dispatcher discovers available actions, describes them, and validates arguments.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$global:dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')


Describe 'Unified Dispatcher — discovery and validation' {
  It 'lists available actions' {
    $json = Get-LabVIEWIconEditorArgsJson
    $out = pwsh -NoProfile -File $global:dispatcher -ListActions -ArgsJson $json | Out-String
    $out | Should -Match 'apply-vipc'
    $out | Should -Match 'build-lvlibp'
    $out | Should -Match 'missing-in-project'
    $out | Should -Match 'run-unit-tests'
  }
  It 'describes a known action (build-lvlibp)' {
    $json = Get-LabVIEWIconEditorArgsJson
    $out = pwsh -NoProfile -File $global:dispatcher -Describe build-lvlibp -ArgsJson $json | Out-String
    $out | Should -Match 'Major'
    $out | Should -Match 'Minor'
    $out | Should -Match 'Patch'
    $out | Should -Match 'Build'
    $out | Should -Match 'Commit'
  }

  It 'fails gracefully on unknown action' {
    $json = Get-LabVIEWIconEditorArgsJson
    pwsh -NoProfile -File $global:dispatcher -ActionName no-such-action -ArgsJson $json *>$null
    $LASTEXITCODE | Should -Be 1
  }
}

Describe 'ArgsJson path handling' {
  It 'handles Windows paths without manual escaping' {
    $json = Get-LabVIEWIconEditorArgsJson
    & $global:dispatcher -ActionName set-development-mode -ArgsJson $json -DryRun *> $null
    $LASTEXITCODE | Should -Be 0
  }
}


Describe 'Filter-Args helper' {
  It 'returns UnknownParams when requested' {
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
    It 'accepts camelCase args' {
      $base = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
      $json = @{
        MinimumSupportedLVVersion = $base.MinimumSupportedLVVersion
        SupportedBitness = $base.SupportedBitness
      } | ConvertTo-Json -Compress
      & $global:dispatcher -ActionName close-labview -ArgsJson $json -DryRun *> $null
      $LASTEXITCODE | Should -Be 0
    }

    It 'accepts snake_case args without warnings' {
      $base = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
      $json = @{
        minimum_supported_lv_version = $base.MinimumSupportedLVVersion
        supported_bitness = $base.SupportedBitness
      } | ConvertTo-Json -Compress
      $out = & $global:dispatcher -ActionName close-labview -ArgsJson $json -DryRun *>&1 | Out-String
      $LASTEXITCODE | Should -Be 0
      $out | Should -Not -Match 'Ignored unknown parameters'
      $out | Should -Not -Match 'Missing an argument'
    }
  }
