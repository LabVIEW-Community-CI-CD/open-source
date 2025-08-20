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
        $out = & $scriptPath -MinimumSupportedLVVersion '2021' -SupportedBitness '64' -RelativePath $repoRoot -DryRun 6>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match 'g-cli --lv-ver 2021 --arch 64'
        $out | Should -Match 'DryRun: Create localhost.library path from ini file'
    }
}
