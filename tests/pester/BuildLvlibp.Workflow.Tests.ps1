#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'BuildLvlibp.Workflow' {
    $meta = @{
        requirement = 'REQ-010'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildLvlibp.Workflow.Tests.ps1'
    }

    It 'runs build-lvlibp action and uploads lvlibp artifact' -Tag 'REQ-010' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/build-lvlibp-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'build-lvlibp'
        $buildStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './build-lvlibp/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/upload-artifact@v4' -and $_['with']['path'] -match '\.lvlibp$' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $buildStep.with.minimum_supported_lv_version | Should -Be '2021'
        $buildStep.with.supported_bitness | Should -Be '64'
        $buildStep.with.relative_path | Should -Be 'scripts/build-lvlibp'
        $buildStep.with.labview_project | Should -Be 'scripts/build-lvlibp/lv_icon.lvproj'
        $buildStep.with.build_spec | Should -Be 'PackedLib Build'

        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.path | Should -Be 'scripts/build-lvlibp/lv_icon.lvlibp'
    }
}
