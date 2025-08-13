#requires -Version 7.0
# Pester v5+ tests that do NOT require LabVIEW/g-cli.
# Run:  Invoke-Pester -CI -Path ./tests/pester

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'

Describe 'Unified Dispatcher — discovery and validation' {
  It 'lists available actions' {
    $out = pwsh -NoProfile -Command "& '$dispatcher' -ListActions"
    $out | Should -Match 'apply-vipc'
    $out | Should -Match 'build-lvlibp'
    $out | Should -Match 'missing-in-project'
    $out | Should -Match 'run-unit-tests'
  }

  It 'describes a known action (build-lvlibp)' {
    $out = pwsh -NoProfile -Command "& '$dispatcher' -Describe build-lvlibp"
    $out | Should -Match 'Major'
    $out | Should -Match 'Minor'
    $out | Should -Match 'Patch'
    $out | Should -Match 'Build'
    $out | Should -Match 'Commit'
  }

  It 'fails gracefully on unknown action' {
    pwsh -NoProfile -Command "& '$dispatcher' -ActionName no-such-action -ArgsJson '{}'" *>$null
    $LASTEXITCODE | Should -Be 1
  }
}

Describe 'Unified Dispatcher — DryRun behavior' {
  It 'apply-vipc honors DryRun and returns 0' {
    $json = '{"MinimumSupportedLVVersion":"2021","VIP_LVVersion":"2021","SupportedBitness":"64","RelativePath":".","VIPCPath":"dummy.vipc"}'
    pwsh -NoProfile -Command "& '$dispatcher' -ActionName apply-vipc -ArgsJson '$json' -DryRun" *>$null
    $LASTEXITCODE | Should -Be 0
  }

  It 'build-lvlibp honors DryRun and returns 0' {
    $json = '{
      "MinimumSupportedLVVersion":"2021",
      "SupportedBitness":"64",
      "RelativePath":".",
      "LabVIEW_Project":"My.lvproj",
      "Build_Spec":"MyBuild",
      "Major":1,"Minor":0,"Patch":0,"Build":1,"Commit":"deadbeef"
    }'
    pwsh -NoProfile -Command "& '$dispatcher' -ActionName build-lvlibp -ArgsJson '$json' -DryRun" *>$null
    $LASTEXITCODE | Should -Be 0
  }

  It 'filters unknown args without crashing' {
    $json = '{"UnknownParam":123}'
    $out = pwsh -NoProfile -Command "& '$dispatcher' -ActionName build-lvlibp -ArgsJson '$json' -DryRun"
    $LASTEXITCODE | Should -Be 0
    $out | Should -Match 'Ignored unknown parameters'
  }
}
