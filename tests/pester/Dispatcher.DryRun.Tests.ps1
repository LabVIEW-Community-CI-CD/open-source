#requires -Version 7.0
# Pester v5+ tests that do NOT require LabVIEW/g-cli.
# Run:  Invoke-Pester -CI -Path ./tests/pester

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$global:dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'Unified Dispatcher — DryRun behavior for all actions' {
  $script:args = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
  $extra = @{
       VIP_LVVersion             = '2021'
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
    }
  foreach ($kvp in $extra.GetEnumerator()) { $script:args | Add-Member -NotePropertyName $kvp.Key -NotePropertyValue $kvp.Value }
  $script:argsJson = $script:args | ConvertTo-Json -Compress
  $actions = pwsh -NoProfile -File $global:dispatcher -ListActions |
    Where-Object { $_ -match '^\s+- ' } |
    ForEach-Object { @{ Action = $_.Trim().Substring(2); ArgsJson = $script:argsJson } }

  It "describes <Action>" -ForEach $actions {
    param($Action, $ArgsJson)
    Write-Host "Testing $Action with ArgsJson $ArgsJson"
    pwsh -NoProfile -File $global:dispatcher -Describe $Action -ArgsJson $ArgsJson *> $null
    $LASTEXITCODE | Should -Be 0
  }

  It "prints description before dry-run <Action>" -ForEach $actions {
    param($Action, $ArgsJson)
    Write-Host "Testing $Action with ArgsJson $ArgsJson"
    $describeOut = & $global:dispatcher -Describe $Action -ArgsJson $ArgsJson 6>&1 | Out-String
    & $global:dispatcher -ActionName $Action -ArgsJson $ArgsJson -DryRun *> $null
    $LASTEXITCODE | Should -Be 0
    $describeOut | Should -Match "$Action parameters:"
  }

  It "dry-runs <Action> and warns on unknown args" -ForEach $actions {
    param($Action, $ArgsJson)
    Write-Host "Testing $Action with ArgsJson $ArgsJson"
    $out = & $global:dispatcher -ActionName $Action -ArgsJson $ArgsJson -DryRun *>&1 | Out-String
    $LASTEXITCODE | Should -Be 0
    $out | Should -Match 'Ignored unknown parameters'
  }
}
