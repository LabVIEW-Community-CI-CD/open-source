#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'BuildProfile1.IconEditor.CloseLabview.Dispatcher' {
    $meta = @{
        requirement = 'REQIE-010'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.CloseLabview.Dispatcher.Tests.ps1'
    }

    It 'dry-runs close-labview with expected arguments [REQIE-010]' -Tag 'REQIE-010' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
        $params = Get-LabVIEWIconEditorArgsJson
        $projectRoot = $params.WorkingDirectory
        $out = & $dispatcher -ActionName close-labview -ArgsJson $params.ArgsJson -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match 'Close_LabVIEW.ps1'
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        $obj = $jsonText | ConvertFrom-Json
        $obj.MinimumSupportedLVVersion | Should -Be '2021'
        $obj.SupportedBitness | Should -Be '64'
    }
}
