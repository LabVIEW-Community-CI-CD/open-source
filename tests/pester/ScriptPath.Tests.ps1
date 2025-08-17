#requires -Version 7.0
# Verify that each action script exists in the expected location.
# Requirement: REQ-004 - Every action script exists at the expected path.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$scriptRoot = Join-Path $repoRoot 'scripts'

$dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
$actionNames = pwsh -NoProfile -File $dispatcher -ListActions |
    Where-Object { $_ -match '^\s+- ' } |
    ForEach-Object { $_.Trim().Substring(2) }

$scriptMap = @{ 'missing-in-project' = 'Invoke-MissingInProjectCLI.ps1' }

$cases = foreach ($name in $actionNames) {
    $dir = Join-Path $scriptRoot $name
    if ($scriptMap.ContainsKey($name)) {
        @{ Name = $name; Path = Join-Path $dir $scriptMap[$name] }
    } else {
        $scriptFile = Get-ChildItem -Path $dir -Filter '*.ps1' -File | Select-Object -First 1
        if ($null -eq $scriptFile) {
            @{ Name = $name; Path = Join-Path $dir "$name.ps1" }
        } else {
            @{ Name = $name; Path = $scriptFile.FullName }
        }
    }
}

Describe 'Action script paths' {
    BeforeEach { Add-TestResult -Property @{ Owner = "DevTools"; Evidence = "tests/pester/ScriptPath.Tests.ps1" } }
    It 'has script for <Name>' -Tag 'REQ-004' -TestCases $cases {
        param($Name, $Path)
        Test-Path $Path | Should -BeTrue
    }
}

