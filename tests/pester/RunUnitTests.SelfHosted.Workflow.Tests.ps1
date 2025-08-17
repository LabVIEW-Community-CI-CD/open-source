#requires -Version 7.0
$env:PSModulePath = (Join-Path $PSScriptRoot 'Modules') + [System.IO.Path]::PathSeparator + $env:PSModulePath
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'RunUnitTests.SelfHosted.Workflow' {
    $meta = @{
        requirement = 'REQ-011'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/RunUnitTests.SelfHosted.Workflow.Tests.ps1'
    }

    It 'runs run-unit-tests action and uploads unit-test results' -Tag 'REQ-011' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/run-unit-tests-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'run-unit-tests'
        $testStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './run-unit-tests/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/upload-artifact@v4' -and $_['with']['path'] -match 'UnitTestReport\.xml' } | Select-Object -First 1

        $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')

        $testStep.with.minimum_supported_lv_version | Should -Be '2021'
        $testStep.with.supported_bitness | Should -Be '64'
        $testStep.with.project_path | Should -Match 'labview-icon-editor.*lv_icon.lvproj$'
        $testStep.with.test_config | Should -Match 'labview-icon-editor.*unittest-config.cfg$'

        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.name | Should -Be 'unit-test-results'
        $artifactStep.with.path | Should -Match 'UnitTestReport\.xml'
    }
}
