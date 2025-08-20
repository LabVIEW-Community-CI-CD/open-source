#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'BuildProfile1.IconEditor.ApplyVipc.Dispatcher' {
    $meta = @{
        requirement = 'REQIE-002'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.ApplyVipc.Dispatcher.Tests.ps1'
    }

    It 'dry-runs apply-vipc with expected arguments [REQIE-002]' -Tag 'REQIE-002' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
        $params = Get-LabVIEWIconEditorArgsJson
        $projectRoot = $params.WorkingDirectory
        $args = $params.ArgsJson | ConvertFrom-Json
        $args | Add-Member -NotePropertyName VIP_LVVersion -NotePropertyValue '2021'
        $args | Add-Member -NotePropertyName VIPCPath -NotePropertyValue 'dummy.vipc'
        $json = $args | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName apply-vipc -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match 'ApplyVIPC.ps1'
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        $obj = $jsonText | ConvertFrom-Json
        $obj.MinimumSupportedLVVersion | Should -Be '2021'
        $obj.SupportedBitness | Should -Be '64'
        $obj.VIP_LVVersion | Should -Be '2021'
        $obj.VIPCPath | Should -Be 'dummy.vipc'
    }
}
