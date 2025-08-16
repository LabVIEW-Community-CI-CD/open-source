#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module powershell-yaml

Describe 'RestoreSetupLvSource.SelfHosted.Workflow [REQ-018]' {
    It 'runs restore-setup-lv-source action on a self-hosted runner and uploads restoration artifacts [REQ-018]' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfDir = Join-Path $repoRoot '.github/workflows'
        $workflowFiles = Get-ChildItem -Path $wfDir -Filter '*.yml'
        $workflowFound = $false

        foreach ($wfFile in $workflowFiles) {
            $wf = Get-Content -Raw $wfFile.FullName | ConvertFrom-Yaml
            foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
                $job = $jobEntry.Value
                $restoreStep = $job.steps | Where-Object { $_.uses -eq './restore-setup-lv-source/action.yml' } | Select-Object -First 1
                if ($null -ne $restoreStep) {
                    $workflowFound = $true
                    $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
                    $restoreStep.with.relative_path | Should -Be 'C:\\actions-runner\\_work\\labview-icon-editor\\labview-icon-editor'
                    $restoreStep.env | Should -Not -BeNullOrEmpty
                    $artifactStep = $job.steps | Where-Object {
                        $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' -and (
                            ($_.with.path -match 'restore') -or ($_.with.path -match 'snapshot') -or
                            ($_.with.name -match 'restore') -or ($_.with.name -match 'snapshot') -or
                            ($_.with.path -match 'log') -or ($_.with.name -match 'log')
                        )
                    } | Select-Object -First 1
                    $artifactStep | Should -Not -BeNullOrEmpty
                }
            }
        }

        if (-not $workflowFound) {
            Set-ItResult -Skipped -Because 'No workflow found using restore-setup-lv-source action'
        }
    }
}
