#requires -Version 7.0
# Pester v5+ tests that do NOT require LabVIEW/g-cli.
# Run:  Invoke-Pester -CI -Path ./tests/pester

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$global:dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'

Describe 'Unified Dispatcher — discovery and validation' {
  It 'lists available actions' {
    $out = pwsh -NoProfile -File $global:dispatcher -ListActions
    $out | Should -Match 'apply-vipc'
    $out | Should -Match 'build-lvlibp'
    $out | Should -Match 'missing-in-project'
    $out | Should -Match 'run-unit-tests'
  }

  It 'describes a known action (build-lvlibp)' {
    $out = pwsh -NoProfile -File $global:dispatcher -Describe build-lvlibp
    $out | Should -Match 'Major'
    $out | Should -Match 'Minor'
    $out | Should -Match 'Patch'
    $out | Should -Match 'Build'
    $out | Should -Match 'Commit'
  }

  It 'fails gracefully on unknown action' {
    pwsh -NoProfile -File $global:dispatcher -ActionName no-such-action -ArgsJson '{}' *>$null
    $LASTEXITCODE | Should -Be 1
  }
}

Describe 'Unified Dispatcher — DryRun behavior for all actions' {
  $actions = pwsh -NoProfile -File $global:dispatcher -ListActions |
    Where-Object { $_ -match '^\s+- ' } |
    ForEach-Object { $_.Trim().Substring(2) }

  $argsJson = (
    @{ MinimumSupportedLVVersion = '2021'
       VIP_LVVersion             = '2021'
       SupportedBitness          = '64'
       RelativePath              = '.'
       VIPCPath                  = 'dummy.vipc'
       LabVIEW_Project           = 'My.lvproj'
       Build_Spec                = 'MyBuild'
       LabVIEWMinorRevision      = '2021'
       VIPBPath                  = 'dummy.vipb'
       LVVersion                 = '2021'
       Arch                      = '64'
       ProjectFile               = 'Project.lvproj'
       Major                     = 1
       Minor                     = 0
       Patch                     = 0
       Build                     = 1
       Commit                    = 'deadbeef'
       DisplayInformationJSON    = '{}' 
       OutputPath                = 'out.txt'
       CompanyName               = 'Company'
       AuthorName                = 'Author'
       CurrentFilename           = 'old.txt'
       NewFilename               = 'new.txt'
       ReleaseNotesFile          = 'notes.md'
       ExtraParam                = 'extra'
    } | ConvertTo-Json -Compress )

  foreach ($name in $actions) {
    $action = $name
    It "describes $action" {
      pwsh -NoProfile -File $global:dispatcher -Describe $action *>$null
      $LASTEXITCODE | Should -Be 0
    }

    It "dry-runs $action and warns on unknown args" {
      $out = pwsh -NoProfile -File $global:dispatcher -ActionName $action -ArgsJson $argsJson -DryRun
      $LASTEXITCODE | Should -Be 0
      $out | Should -Match 'Ignored unknown parameters'
    }
  }
}
