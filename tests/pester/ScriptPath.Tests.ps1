#requires -Version 7.0
# Verify that each action script exists in the expected location.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$scriptRoot = Join-Path $repoRoot 'scripts'

$dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
$actionNames = pwsh -NoProfile -File $dispatcher -ListActions |
    Where-Object { $_ -match '^\s+- ' } |
    ForEach-Object { $_.Trim().Substring(2) }

$cases = foreach ($name in $actionNames) {
    $dir = Join-Path $scriptRoot $name
    $scriptFile = Get-ChildItem -Path $dir -Filter '*.ps1' -File | Select-Object -First 1
    if ($null -eq $scriptFile) {
        @{ Name = $name; Path = Join-Path $dir "$name.ps1" }
    } else {
        @{ Name = $name; Path = $scriptFile.FullName }
    }
}

Describe 'Action script paths' {
    It 'has script for <Name>' -TestCases $cases {
        param($Name, $Path)
        Test-Path $Path | Should -BeTrue
    }
}

