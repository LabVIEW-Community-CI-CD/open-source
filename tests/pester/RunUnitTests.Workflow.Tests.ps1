#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'RunUnitTests.Workflow' {
    $meta = @{
        requirement = 'REQ-020'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/RunUnitTests.Workflow.Tests.ps1'
    }

    It 'runs run-unit-tests action and uploads unit-test results' -Tag 'REQ-011' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/run-unit-tests-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'run-unit-tests'
        $testStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './run-unit-tests/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/upload-artifact@v4' -and $_['with']['path'] -match 'UnitTestReport\.xml' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $testStep.with.minimum_supported_lv_version | Should -Be '2021'
        $testStep.with.supported_bitness | Should -Be '64'
        $testStep.with.project_path | Should -Be 'scripts/run-unit-tests/lv_icon.lvproj'
        $testStep.with.test_config | Should -Be 'scripts/run-unit-tests/unittest-config.cfg'
        $testStep.with.working_directory | Should -Be 'scripts/run-unit-tests'

        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.name | Should -Be 'unit-test-results'
        $artifactStep.with.path | Should -Be 'scripts/run-unit-tests/UnitTestReport.xml'
    }
}
