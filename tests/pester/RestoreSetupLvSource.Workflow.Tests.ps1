#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'RestoreSetupLvSource.Workflow' {
    $meta = @{
        requirement = 'REQ-018'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/RestoreSetupLvSource.Workflow.Tests.ps1'
    }

    It 'runs restore-setup-lv-source action and uploads restoration artifacts' -Tag 'REQ-018' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/restore-setup-lv-source-self-hosted.json'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Json -AsHashtable
        $job = $wf.jobs.'restore-setup-lv-source'
        $restoreStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq './restore-setup-lv-source/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $restoreStep.with.relative_path | Should -Be 'scripts/restore-setup-lv-source'
        $restoreStep.env | Should -Not -BeNullOrEmpty

        $artifactStep.with.path | Should -Be 'scripts/restore-setup-lv-source/restore.log'
    }
}
