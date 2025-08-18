#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'PrepareLabviewSource.Workflow' {
    $meta = @{
        requirement = 'REQ-016'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/PrepareLabviewSource.Workflow.Tests.ps1'
    }

    It 'runs prepare-labview-source action and uploads prepared source artifact' -Tag 'REQ-016' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/prepare-labview-source-self-hosted.json'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Json -AsHashtable
        $job = $wf.jobs.'prepare-labview-source'
        $prepareStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq './prepare-labview-source/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $prepareStep.with.relative_path | Should -Be 'scripts/prepare-labview-source'
        $prepareStep.with.labview_project | Should -Be 'scripts/prepare-labview-source/lv_icon.lvproj'
        $prepareStep.with.build_spec | Should -Be 'PackageSource'

        $artifactStep.with.path | Should -Be 'scripts/prepare-labview-source/prepared-source.zip'
    }
}
