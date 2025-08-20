#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'BuildProfile1.IconEditor.AddTokenToLabview.Dispatcher' {
    $meta = @{
        requirement = 'REQIE-001'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.AddTokenToLabview.Dispatcher.Tests.ps1'
    }

    It 'dry-runs add-token-to-labview with expected arguments [REQIE-001]' -Tag 'REQIE-001' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
        $params = Get-LabVIEWIconEditorArgsJson
        $projectRoot = $params.WorkingDirectory
        $out = & $dispatcher -ActionName add-token-to-labview -ArgsJson $params.ArgsJson -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match 'AddTokenToLabVIEW.ps1'
        $out | Should -Match 'g-cli --lv-ver 2021 --arch 64'
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        $obj = $jsonText | ConvertFrom-Json
        $obj.MinimumSupportedLVVersion | Should -Be '2021'
        $obj.SupportedBitness | Should -Be '64'
        $obj.RelativePath | Should -Be '.'
    }
}
