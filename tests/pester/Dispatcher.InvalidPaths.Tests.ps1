#requires -Version 7.0
# Pester v5+ tests verifying dispatcher handling of invalid RelativePath
# Requirement: REQ-005 - Dispatcher fails when RelativePath is missing or invalid.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot   = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$global:dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'Invalid RelativePath handling' {
    BeforeEach { Add-TestResult -Property @{ Owner = "DevTools"; Evidence = "tests/pester/Dispatcher.InvalidPaths.Tests.ps1" } }
    It 'fails when RelativePath does not exist' -Tag 'REQ-005' {
        $json = @{ RelativePath = 'NoSuchDir' } | ConvertTo-Json -Compress
        $out = pwsh -NonInteractive -NoProfile -File $global:dispatcher -ActionName set-development-mode -ArgsJson $json *>&1 | Out-String
        $LASTEXITCODE | Should -Not -Be 0
        $out | Should -Match 'An unexpected error occurred during script execution'
    }

    It 'fails when RelativePath is missing' -Tag 'REQ-005' {
        $out = pwsh -NonInteractive -NoProfile -File $global:dispatcher -ActionName set-development-mode -ArgsJson '{}' *>&1 | Out-String
        $LASTEXITCODE | Should -Not -Be 0
        $out | Should -Match 'missing mandatory'
        $out | Should -Match 'RelativePath'
    }
}
