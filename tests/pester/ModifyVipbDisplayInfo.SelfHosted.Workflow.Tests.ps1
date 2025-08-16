#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module powershell-yaml

Describe 'ModifyVipbDisplayInfo.SelfHosted.Workflow [REQ-015]' {
    It 'runs modify-vipb-display-info action on a self-hosted runner and uploads VIPB artifact [REQ-015]' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfDir = Join-Path $repoRoot '.github/workflows'
        $workflowFiles = Get-ChildItem -Path $wfDir -Filter '*.yml'
        $workflowFound = $false

        foreach ($wfFile in $workflowFiles) {
            $wf = Get-Content -Raw $wfFile.FullName | ConvertFrom-Yaml
            foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
                $job = $jobEntry.Value
                $modStep = $job.steps | Where-Object { $_.uses -eq './modify-vipb-display-info/action.yml' } | Select-Object -First 1
                if ($null -ne $modStep) {
                    $workflowFound = $true
                    $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
                    $modStep.uses | Should -Be './modify-vipb-display-info/action.yml'
                    $modStep.with.supported_bitness | Should -Not -BeNullOrEmpty
                    $modStep.with.relative_path | Should -Not -BeNullOrEmpty
                    $modStep.with.vipb_path | Should -Not -BeNullOrEmpty
                    $modStep.with.minimum_supported_lv_version | Should -Not -BeNullOrEmpty
                    $modStep.with.labview_minor_revision | Should -Not -BeNullOrEmpty
                    $modStep.with.major | Should -Not -BeNullOrEmpty
                    $modStep.with.minor | Should -Not -BeNullOrEmpty
                    $modStep.with.patch | Should -Not -BeNullOrEmpty
                    $modStep.with.build | Should -Not -BeNullOrEmpty
                    $modStep.with.commit | Should -Not -BeNullOrEmpty
                    $modStep.with.display_information_json | Should -Not -BeNullOrEmpty
                    $artifactStep = $job.steps | Where-Object {
                        $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' -and (
                            ($_.with.path -match '\.vipb') -or ($_.with.path -match '\.log')
                        )
                    } | Select-Object -First 1
                    $artifactStep | Should -Not -BeNullOrEmpty
                }
            }
        }

        if (-not $workflowFound) {
            Set-ItResult -Skipped -Because 'No workflow found using modify-vipb-display-info action'
        }
    }
}
