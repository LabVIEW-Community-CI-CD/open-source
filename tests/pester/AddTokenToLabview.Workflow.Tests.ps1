#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'


Describe 'AddTokenToLabview.Workflow' {
    $meta = @{
        requirement = 'REQ-008'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/AddTokenToLabview.Workflow.Tests.ps1'
    }

    It 'runs add-token-to-labview action and uploads token artifact' -Tag 'REQ-008' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/add-token-to-labview-self-hosted.json'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Json -AsHashtable
        $job = $wf.jobs.'add-token'
        $addStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq './add-token-to-labview/action.yml' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $addStep.with.minimum_supported_lv_version | Should -Be '2021'
        $addStep.with.supported_bitness | Should -Be '64'
        $addStep.with.relative_path | Should -Be 'scripts/add-token-to-labview'

        $uploadStep = $job.steps | Where-Object {
            $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*'
        } | Select-Object -First 1
        $uploadStep.with.path | Should -Be 'scripts/add-token-to-labview/LabVIEW.ini'
    }
}
