#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'BuildViPackage.Workflow' {
    $meta = @{
        requirement = 'REQ-011'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildViPackage.Workflow.Tests.ps1'
    }

    It 'runs build-vi-package action and uploads vi package artifact' -Tag 'REQ-011' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/build-vi-package-self-hosted.yml'
        if (-not (Test-Path $workflowPath)) {
            Set-ItResult -Skipped -Because 'Workflow file not found'
            return
        }
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'build-vi-package'
        $buildStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './build-vi-package/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/upload-artifact@v4' -and $_['with']['path'] -match '\.vip$' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $buildStep.with.relative_path | Should -Be 'scripts/build-vi-package'
        $buildStep.with.vipb_path | Should -Be 'scripts/build-vi-package/NI Icon editor.vipb'
        $buildStep.with.major | Should -Be '1'
        $buildStep.with.minor | Should -Be '0'
        $buildStep.with.patch | Should -Be '0'
        $buildStep.with.build | Should -Be '1'
        $buildStep.with.commit | Should -Be 'abcdef'

        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.path | Should -Be 'scripts/build-vi-package/lv_icon.vip'
        $artifactStep.with.name | Should -Be 'vi-package'
    }
}
