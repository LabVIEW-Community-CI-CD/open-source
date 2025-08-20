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
        $captured = $null
        Mock Invoke-Expression { param($cmd) $script:captured = $cmd }
        & $scriptPath -MinimumSupportedLVVersion '2021' -SupportedBitness '64' *> $null
        Assert-MockCalled Invoke-Expression -Exactly 1 -Scope It
        $captured | Should -Match 'g-cli --lv-ver 2021 --arch 64 QuitLabVIEW'
    }
}
