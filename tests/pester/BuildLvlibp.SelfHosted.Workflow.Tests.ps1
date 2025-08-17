#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
    try {
        Import-Module powershell-yaml -ErrorAction Stop
    }
    catch {
        Set-ItResult -Skipped -Because 'powershell-yaml module not installed'
        return
    }
}

Describe 'BuildLvlibp.SelfHosted.Workflow' {
    BeforeEach { Add-TestResult -Property @{ Owner = "DevTools"; Evidence = "tests/pester/BuildLvlibp.SelfHosted.Workflow.Tests.ps1" } }
    It 'runs build-lvlibp action and uploads lvlibp artifact' -Tag 'REQ-010' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/build-lvlibp-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'build-lvlibp'
        $buildStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './build-lvlibp/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/upload-artifact@v4' -and $_['with']['path'] -match '\.lvlibp$' } | Select-Object -First 1

        $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')

        $buildStep.with.minimum_supported_lv_version | Should -Be '2021'
        $buildStep.with.supported_bitness | Should -Be '64'
        $buildStep.with.labview_project | Should -Match 'labview-icon-editor.*lv_icon.lvproj$'
        $buildStep.with.build_spec | Should -Be 'PackedLib Build'

        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.path | Should -Match '\.lvlibp$'
    }
}
