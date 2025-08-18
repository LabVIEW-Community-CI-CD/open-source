#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'ApplyVipc.DryRunTrue.Workflow' {
    $meta = @{
        requirement = 'REQ-006'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/ApplyVipc.Workflow.Tests.ps1'
    }

    It 'runs apply-vipc action with dry_run true' -Tag 'REQ-006' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/apply-vipc-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'apply-vipc'
        $applyStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './apply-vipc/action.yml' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'

        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $applyStep.uses | Should -Be './apply-vipc/action.yml'
        $applyStep.with.minimum_supported_lv_version | Should -Be '2021'
        $applyStep.with.vip_lv_version | Should -Be '2021'
        $applyStep.with.supported_bitness | Should -Be '64'
        $applyStep.with.relative_path | Should -Be '.'
        $applyStep.with.vipc_path | Should -Be 'scripts/apply-vipc/runner_dependencies.vipc'
        $applyStep.with.dry_run | Should -Be $true
    }
}
