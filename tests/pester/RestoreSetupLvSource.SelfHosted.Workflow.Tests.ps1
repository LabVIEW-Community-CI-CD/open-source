#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
    try {
        Import-Module powershell-yaml -ErrorAction Stop
    }
    catch {
        Set-ItResult -Skipped -Because 'powershell-yaml module not installed'
        return
    }
}

Describe 'RestoreSetupLvSource.SelfHosted.Workflow' {
    BeforeEach { Add-TestResult -Property @{ Owner = "DevTools"; Evidence = "tests/pester/RestoreSetupLvSource.SelfHosted.Workflow.Tests.ps1" } }
    It 'runs restore-setup-lv-source action on a self-hosted runner and uploads restoration artifacts' -Tag 'REQ-018' {
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
                    $restoreStep.with.relative_path | Should -Match 'labview-icon-editor$'
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
