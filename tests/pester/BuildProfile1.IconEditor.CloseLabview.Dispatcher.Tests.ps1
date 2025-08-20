#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'BuildProfile1.IconEditor.CloseLabview.Dispatcher' {
    $meta = @{
        requirement = 'REQIE-010'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.CloseLabview.Dispatcher.Tests.ps1'
    }

    It 'invokes close-labview via dispatcher [REQIE-010]' -Tag 'REQIE-010' {
        $params = Get-LabVIEWIconEditorArgsJson
        $json = $params.ArgsJson
        $projectRoot = $params.WorkingDirectory
        $out = & $dispatcher -ActionName close-labview -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match 'Close_LabVIEW.ps1'
        $out | Should -Match '"MinimumSupportedLVVersion":"2021"'
        $out | Should -Match '"SupportedBitness":"64"'
    }
}
