#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'SetDevelopmentMode.Workflow' {
    $meta = @{
        requirement = 'REQ-021'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/SetDevelopmentMode.Workflow.Tests.ps1'
    }

    It 'runs set-development-mode action and uploads logs' -Tag 'REQ-021' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/set-development-mode-self-hosted.json'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Json -AsHashtable
        $job = $wf.jobs.'set-development-mode'
        $setStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq './set-development-mode/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $setStep.with.relative_path | Should -Be 'scripts/set-development-mode'
        $setStep.with.gcli_path | Should -Be 'scripts/set-development-mode/g-cli.exe'
        $setStep.with.working_directory | Should -Be 'scripts/set-development-mode'
        $setStep.with.log_level | Should -Be 'INFO'
        $setStep.with.dry_run | Should -Be 'true'

        $artifactStep.with.path | Should -Be 'scripts/set-development-mode/dev-mode.log'
    }
}
