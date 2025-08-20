#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'BuildProfile1.IconEditor.AddTokenToLabview.Script' {
    $meta = @{
        requirement = 'REQIE-001'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.AddTokenToLabview.Script.Tests.ps1'
    }

    It 'invokes AddTokenToLabVIEW with expected arguments [REQIE-001]' -Tag 'REQIE-001' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $scriptPath = Join-Path $repoRoot 'scripts' 'add-token-to-labview' 'AddTokenToLabVIEW.ps1'
        $captured = $null
        Mock g-cli { $script:captured = $args }
        & $scriptPath -MinimumSupportedLVVersion '2021' -SupportedBitness '64' -RelativePath $repoRoot *> $null
        Assert-MockCalled g-cli -Exactly 1 -Scope It
        $captured | Should -Contain '--lv-ver'
        $captured | Should -Contain '2021'
        $captured | Should -Contain '--arch'
        $captured | Should -Contain '64'
    }
}
