#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'Build.Workflow' {
    $meta = @{
        requirement = 'REQ-009'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/Build.Workflow.Tests.ps1'
    }

    It 'runs build action with required inputs' -Tag 'REQ-009' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/build-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'build'
        $buildStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './build/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/upload-artifact@v4' -and $_['with']['path'] -match 'lv_icon_x64\.lvlibp' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $buildStep.with.relative_path | Should -Be 'scripts/build'
        $buildStep.with.major | Should -Be '1'
        $buildStep.with.minor | Should -Be '0'
        $buildStep.with.patch | Should -Be '0'
        $buildStep.with.build | Should -Be '1'
        $buildStep.with.commit | Should -Be 'abcdef'
        $buildStep.with.labview_minor_revision | Should -Be '3'
        $buildStep.with.company_name | Should -Be 'Acme Corp'
        $buildStep.with.author_name | Should -Be 'Jane Doe'

        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.path | Should -Be 'scripts/build/lv_icon_x64.lvlibp'
        $artifactStep.with.name | Should -Be 'build-artifact'
    }
}
