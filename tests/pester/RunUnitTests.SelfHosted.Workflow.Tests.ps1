#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module powershell-yaml

Describe 'RunUnitTests.SelfHosted.Workflow [REQ-011]' {
    It 'runs run-unit-tests action and uploads unit-test results [REQ-011]' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/run-unit-tests-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'run-unit-tests'
        $testStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './run-unit-tests/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/upload-artifact@v4' -and $_['with']['path'] -match 'UnitTestReport\.xml' } | Select-Object -First 1

        $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')

        $testStep.with.minimum_supported_lv_version | Should -Be '2021'
        $testStep.with.supported_bitness | Should -Be '64'
        $testStep.with.project_path | Should -Be 'C:\\actions-runner\\_work\\labview-icon-editor\\labview-icon-editor\\source\\lv_icon.lvproj'
        $testStep.with.test_config | Should -Be 'C:\\actions-runner\\_work\\labview-icon-editor\\labview-icon-editor\\tests\\unittest-config.cfg'

        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.name | Should -Be 'unit-test-results'
        $artifactStep.with.path | Should -Match 'UnitTestReport\.xml'
    }
}
