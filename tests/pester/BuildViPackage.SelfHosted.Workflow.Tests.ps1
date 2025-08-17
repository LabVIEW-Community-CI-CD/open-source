#requires -Version 7.0
$env:PSModulePath = (Join-Path $PSScriptRoot 'Modules') + [System.IO.Path]::PathSeparator + $env:PSModulePath
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'BuildViPackage.SelfHosted.Workflow' {
    $meta = @{
        requirement = 'REQ-011'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildViPackage.SelfHosted.Workflow.Tests.ps1'
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

        $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')

        $buildStep.with.vipb_path | Should -Match 'labview-icon-editor.*NI Icon editor.vipb$'
        $buildStep.with.major | Should -Be '1'
        $buildStep.with.minor | Should -Be '0'
        $buildStep.with.patch | Should -Be '0'
        $buildStep.with.build | Should -Be '2'
        $buildStep.with.commit | Should -Be 'abcdef'

        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.path | Should -Match '\.vip$'
        $artifactStep.with.name | Should -Be 'build-vi-package-artifact'
    }
}
