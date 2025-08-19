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
        $workflowPath = Join-Path $repoRoot '.github/workflows/build-self-hosted.json'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Json -AsHashtable
        $job = $wf.jobs.'build'
        $buildStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './build/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.name -eq 'Upload build artifact' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $buildStep.with.relative_path | Should -Be 'scripts/build'
        $buildStep.with.major | Should -Be '${{ env.MAJOR }}'
        $buildStep.with.minor | Should -Be '${{ env.MINOR }}'
        $buildStep.with.patch | Should -Be '${{ env.PATCH }}'
        $buildStep.with.build | Should -Be '${{ github.run_number }}'
        $buildStep.with.commit | Should -Be '${{ github.sha }}'
        $buildStep.with.labview_minor_revision | Should -Be '3'
        $buildStep.with.company_name | Should -Be 'Acme Corp'
        $buildStep.with.author_name | Should -Be 'Jane Doe'

        $artifactMeta = $job.steps | Where-Object { $_.name -eq 'Record artifact metadata' } | Select-Object -First 1
        $manifestStep = $job.steps | Where-Object { $_.name -eq 'Upload artifact manifest' } | Select-Object -First 1

        $artifactMeta | Should -Not -BeNullOrEmpty
        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.path | Should -Be 'scripts/build/${{ steps.record.outputs.artifact }}'
        $artifactStep.with.name | Should -Be '${{ steps.record.outputs.artifact }}'
        $manifestStep | Should -Not -BeNullOrEmpty
        $manifestStep.with.path | Should -Be 'scripts/build/artifact-manifest.json'
        $manifestStep.with.name | Should -Be 'artifact-manifest'
    }
}
