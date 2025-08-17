#requires -Version 7.0
$env:PSModulePath = (Join-Path $PSScriptRoot 'Modules') + [System.IO.Path]::PathSeparator + $env:PSModulePath
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'ApplyVipc.SelfHosted.DryRunTrue.Workflow' {
    $meta = @{
        requirement = 'REQ-006'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/ApplyVipc.SelfHosted.Workflow.Tests.ps1'
    }

    It 'runs apply-vipc action with dry_run true' -Tag 'REQ-006' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/apply-vipc-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'apply-vipc'
        $applyStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './apply-vipc/action.yml' } | Select-Object -First 1
        $checkoutIconRepoStep = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with']['repository'] -eq 'LabVIEW-Community-CI-CD/labview-icon-editor' } | Select-Object -First 1

        $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
        $job.strategy.matrix.dry_run | Should -Contain $true

        $checkoutIconRepoStep.uses | Should -Be 'actions/checkout@v4'
        $checkoutIconRepoStep.with.path | Should -Match 'labview-icon-editor/labview-icon-editor$'

        $applyStep.uses | Should -Be './apply-vipc/action.yml'
        $applyStep.with.minimum_supported_lv_version | Should -Be '2021'
        $applyStep.with.vip_lv_version | Should -Be '2021'
        $applyStep.with.supported_bitness | Should -Be '64'
        $applyStep.with.relative_path | Should -Match 'labview-icon-editor$'
        $applyStep.with.vipc_path | Should -Match 'labview-icon-editor.*runner_dependencies.vipc$'
        $applyStep.with.dry_run | Should -Be '${{ matrix.dry_run }}'
    }
}

Describe 'ApplyVipc.SelfHosted.DryRunFalse.Workflow' {
    $meta = @{
        requirement = 'REQ-007'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/ApplyVipc.SelfHosted.Workflow.Tests.ps1'
    }

    It 'runs apply-vipc action with dry_run false' -Tag 'REQ-007' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/apply-vipc-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'apply-vipc'
        $applyStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './apply-vipc/action.yml' } | Select-Object -First 1
        $checkoutIconRepoStep = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with']['repository'] -eq 'LabVIEW-Community-CI-CD/labview-icon-editor' } | Select-Object -First 1

        $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
        $job.strategy.matrix.dry_run | Should -Contain $false

        $checkoutIconRepoStep.uses | Should -Be 'actions/checkout@v4'
        $checkoutIconRepoStep.with.path | Should -Match 'labview-icon-editor/labview-icon-editor$'

        $applyStep.uses | Should -Be './apply-vipc/action.yml'
        $applyStep.with.minimum_supported_lv_version | Should -Be '2021'
        $applyStep.with.vip_lv_version | Should -Be '2021'
        $applyStep.with.supported_bitness | Should -Be '64'
        $applyStep.with.relative_path | Should -Match 'labview-icon-editor$'
        $applyStep.with.vipc_path | Should -Match 'labview-icon-editor.*runner_dependencies.vipc$'
        $applyStep.with.dry_run | Should -Be '${{ matrix.dry_run }}'
    }
}
