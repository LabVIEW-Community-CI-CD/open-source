#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'BuildProfile1.IconEditor.BuildViPackage.Dispatcher' {
    $meta = @{
        requirement = 'REQIE-008'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.BuildViPackage.Dispatcher.Tests.ps1'
    }

    It 'invokes build-vi-package via dispatcher [REQIE-008]' -Tag 'REQIE-008' {
        $params = Get-LabVIEWIconEditorArgsJson
        $base = $params.ArgsJson | ConvertFrom-Json
        $vipbPath = Join-Path $repoRoot 'scripts' 'build-vi-package' 'NI Icon editor.vipb'
        $releaseNotes = Join-Path $repoRoot 'scripts' 'build-vi-package' 'release-notes.md'
        $base | Add-Member LabVIEWMinorRevision '3'
        $base | Add-Member VIPBPath $vipbPath
        $base | Add-Member Major 1
        $base | Add-Member Minor 0
        $base | Add-Member Patch 0
        $base | Add-Member Build 2
        $base | Add-Member Commit 'abcdef0'
        $base | Add-Member DisplayInformationJSON '{"Package Version":{"major":1,"minor":0,"patch":0,"build":2}}'
        $base | Add-Member ReleaseNotesFile $releaseNotes
        $json = $base | ConvertTo-Json -Compress
        $projectRoot = $params.WorkingDirectory
        $out = & $dispatcher -ActionName build-vi-package -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match 'build_vip.ps1'
        $out | Should -Match [regex]::Escape('NI Icon editor.vipb')
        $out | Should -Match '"Commit":"abcdef0"'
    }
}
