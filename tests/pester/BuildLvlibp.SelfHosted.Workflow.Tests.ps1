#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module powershell-yaml

Describe 'BuildLvlibp.SelfHosted.Workflow [REQ-010]' {
    It 'runs build-lvlibp action and uploads lvlibp artifact [REQ-010]' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/build-lvlibp-self-hosted.yml'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Yaml
        $job = $wf.jobs.'build-lvlibp'
        $buildStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq './build-lvlibp/action.yml' } | Select-Object -First 1
        $artifactStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_['uses'] -eq 'actions/upload-artifact@v4' -and $_['with']['path'] -match '\.lvlibp$' } | Select-Object -First 1

        $job.'runs-on' | Should -Be @('self-hosted','self-hosted-windows-lv')

        $buildStep.with.minimum_supported_lv_version | Should -Be '2021'
        $buildStep.with.supported_bitness | Should -Be '64'
        $buildStep.with.labview_project | Should -Be 'C:\\actions-runner\\_work\\labview-icon-editor\\labview-icon-editor\\source\\lv_icon.lvproj'
        $buildStep.with.build_spec | Should -Be 'PackedLib Build'

        $artifactStep | Should -Not -BeNullOrEmpty
        $artifactStep.with.path | Should -Match '\.lvlibp$'
    }
}
