#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'BuildProfile1.IconEditor.BuildViPackage.Dispatcher' {
    $meta = @{
        requirement = 'REQIE-008'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.BuildViPackage.Dispatcher.Tests.ps1'
    }

    It 'dry-runs build-vi-package with expected arguments [REQIE-008]' -Tag 'REQIE-008' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
        $params = Get-LabVIEWIconEditorArgsJson
        $projectRoot = $params.WorkingDirectory
        $args = $params.ArgsJson | ConvertFrom-Json
        $args | Add-Member -NotePropertyName LabVIEWMinorRevision -NotePropertyValue '2021'
        $args | Add-Member -NotePropertyName VIPBPath -NotePropertyValue 'dummy.vipb'
        $args | Add-Member -NotePropertyName Major -NotePropertyValue 1
        $args | Add-Member -NotePropertyName Minor -NotePropertyValue 0
        $args | Add-Member -NotePropertyName Patch -NotePropertyValue 0
        $args | Add-Member -NotePropertyName Build -NotePropertyValue 2
        $args | Add-Member -NotePropertyName Commit -NotePropertyValue 'abcdef0'
        $args | Add-Member -NotePropertyName DisplayInformationJSON -NotePropertyValue '{}'
        $json = $args | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName build-vi-package -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match 'build_vip.ps1'
        $out | Should -Match 'g-cli --lv-ver 2021 --arch 64'
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        $obj = $jsonText | ConvertFrom-Json
        $obj.MinimumSupportedLVVersion | Should -Be '2021'
        $obj.SupportedBitness | Should -Be '64'
        $obj.VIPBPath | Should -Be 'dummy.vipb'
        $obj.Commit | Should -Be 'abcdef0'
    }
}
