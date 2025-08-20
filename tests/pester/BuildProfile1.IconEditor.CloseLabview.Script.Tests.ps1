#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'BuildProfile1.IconEditor.CloseLabview.Script' {
    $meta = @{
        requirement = 'REQIE-010'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.CloseLabview.Script.Tests.ps1'
    }

    It 'constructs g-cli QuitLabVIEW command without executing [REQIE-010]' -Tag 'REQIE-010' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $scriptPath = Join-Path $repoRoot 'scripts' 'close-labview' 'Close_LabVIEW.ps1'
        $out = & $scriptPath -MinimumSupportedLVVersion '2021' -SupportedBitness '64' -DryRun *>&1 | Out-String
        $out | Should -Match 'g-cli --lv-ver 2021 --arch 64 QuitLabVIEW'
        $out | Should -Match 'DryRun: Close LabVIEW 2021 (64-bit)'
    }
}
