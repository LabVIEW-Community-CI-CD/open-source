#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'MissingInProject.Workflow' {
    $meta = @{
        requirement = 'REQ-014'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/MissingInProject.Workflow.Tests.ps1'
    }

    It 'runs missing-in-project action and uploads findings report' -Tag 'REQ-014' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/missing-in-project-self-hosted.json'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Json -AsHashtable
        $job = $wf.jobs.'missing-in-project'
        $missingStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq './missing-in-project/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $missingStep.with.lv_version | Should -Be '2021'
        $missingStep.with.arch | Should -Be '64'
        $missingStep.with.project_file | Should -Be 'scripts/missing-in-project/Missing in Project.lvproj'
        $missingStep.with.relative_path | Should -Be 'scripts/missing-in-project'

        $artifactStep.with.path | Should -Be 'scripts/missing-in-project/missing_files.txt'
    }
}
