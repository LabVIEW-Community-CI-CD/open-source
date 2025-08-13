#requires -Version 7.0
# Pester v5+ tests that do NOT require LabVIEW/g-cli.
# Run:  Invoke-Pester -CI -Path ./tests/pester

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$global:dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'

Describe 'Unified Dispatcher — discovery and validation' {
  It 'lists available actions' {
    $out = pwsh -NoProfile -File $global:dispatcher -ListActions | Out-String
    $out | Should -Match 'apply-vipc'
    $out | Should -Match 'build-lvlibp'
    $out | Should -Match 'missing-in-project'
    $out | Should -Match 'run-unit-tests'
  }

  It 'describes a known action (build-lvlibp)' {
    $out = pwsh -NoProfile -File $global:dispatcher -Describe build-lvlibp | Out-String
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
    ForEach-Object { @{ Action = $_.Trim().Substring(2) } }

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

  It "describes <Action>" -ForEach $actions {
    param($Action)
    pwsh -NoProfile -File $global:dispatcher -Describe $Action *> $null
    $LASTEXITCODE | Should -Be 0
  }

  It "dry-runs <Action> and warns on unknown args" -ForEach $actions {
    param($Action)
    $out = pwsh -NoProfile -File $global:dispatcher -ActionName $Action -ArgsJson $argsJson -DryRun | Out-String
    $LASTEXITCODE | Should -Be 0
    $out | Should -Match 'Ignored unknown parameters'
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
