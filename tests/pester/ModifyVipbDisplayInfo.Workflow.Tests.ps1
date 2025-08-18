#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'ModifyVipbDisplayInfo.Workflow' {
    $meta = @{
        requirement = 'REQ-015'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/ModifyVipbDisplayInfo.Workflow.Tests.ps1'
    }

    It 'runs modify-vipb-display-info action and uploads VIPB artifact' -Tag 'REQ-015' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/modify-vipb-display-info-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'modify-vipb-display-info'
        $modStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq './modify-vipb-display-info/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $modStep.with.supported_bitness | Should -Be '64'
        $modStep.with.relative_path | Should -Be 'scripts/modify-vipb-display-info'
        $modStep.with.vipb_path | Should -Be 'scripts/modify-vipb-display-info/lv_icon.vipb'
        $modStep.with.minimum_supported_lv_version | Should -Be '2021'
        $modStep.with.labview_minor_revision | Should -Be '0'
        $modStep.with.major | Should -Be '1'
        $modStep.with.minor | Should -Be '0'
        $modStep.with.patch | Should -Be '0'
        $modStep.with.build | Should -Be '1'
        $modStep.with.commit | Should -Be 'abcdef'
        $modStep.with.display_information_json | Should -Be '{"Name":"Test"}'

        $artifactStep.with.path | Should -Be 'scripts/modify-vipb-display-info/lv_icon.vipb'
    }
}
