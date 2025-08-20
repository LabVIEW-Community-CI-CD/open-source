#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'BuildProfile1.IconEditor.ApplyVipc.Script' {
    $meta = @{
        requirement = 'REQIE-002'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.ApplyVipc.Script.Tests.ps1'
    }

    It 'constructs g-cli commands without executing [REQIE-002]' -Tag 'REQIE-002' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $scriptPath = Join-Path $repoRoot 'scripts' 'apply-vipc' 'ApplyVIPC.ps1'
        $vipcPath = Join-Path $repoRoot 'scripts' 'apply-vipc' 'runner_dependencies.vipc'
        $captured = $null
        Mock Invoke-Expression { param($cmd) $script:captured = $cmd }
        & $scriptPath -MinimumSupportedLVVersion '2021' -VIP_LVVersion '2021' -SupportedBitness '64' -RelativePath $repoRoot -VIPCPath $vipcPath *> $null
        Assert-MockCalled Invoke-Expression -Exactly 1 -Scope It
        $captured | Should -Match 'g-cli --lv-ver 2021 --arch 64'
        $captured | Should -Match [regex]::Escape($vipcPath)
    }
}
