#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'BuildProfile1.IconEditor.BuildViPackage.Script' {
    $meta = @{
        requirement = 'REQIE-008'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.BuildViPackage.Script.Tests.ps1'
    }

    It 'constructs g-cli vipb command without executing [REQIE-008]' -Tag 'REQIE-008' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $scriptPath = Join-Path $repoRoot 'scripts' 'build-vi-package' 'build_vip.ps1'
        $releaseNotes = Join-Path $repoRoot 'scripts' 'build-vi-package' 'release-notes.md'
        $json = '{"Package Version":{"major":1,"minor":0,"patch":0,"build":2}}'
        $out = & $scriptPath -SupportedBitness '64' -MinimumSupportedLVVersion 2021 -LabVIEWMinorRevision 3 -Major 1 -Minor 0 -Patch 0 -Build 2 -Commit 'abcdef0' -ReleaseNotesFile $releaseNotes -DisplayInformationJSON $json -DryRun 6>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match 'g-cli --lv-ver 2021 --arch 64 vipb'
        $out | Should -Match 'DryRun: Successfully built VI package'
    }
}
