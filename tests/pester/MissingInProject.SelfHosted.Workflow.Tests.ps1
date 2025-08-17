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

Describe 'MissingInProject.SelfHosted.Workflow' {
    BeforeEach { Add-TestResult -Property @{ Owner = "DevTools"; Evidence = "tests/pester/MissingInProject.SelfHosted.Workflow.Tests.ps1" } }
    It 'runs missing-in-project action on a self-hosted runner and uploads findings report' -Tag 'REQ-014' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfDir = Join-Path $repoRoot '.github/workflows'
        $workflowFiles = Get-ChildItem -Path $wfDir -Filter '*.yml'
        $workflowFound = $false

        foreach ($wfFile in $workflowFiles) {
            $wf = Get-Content -Raw $wfFile.FullName | ConvertFrom-Yaml
            foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
                $job = $jobEntry.Value
                $missingStep = $job.steps | Where-Object { $_.uses -eq './missing-in-project/action.yml' } | Select-Object -First 1
                if ($null -ne $missingStep) {
                    $workflowFound = $true
                    $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
                    $missingStep.uses | Should -Be './missing-in-project/action.yml'
                    $missingStep.with.lv_version | Should -Not -BeNullOrEmpty
                    $missingStep.with.arch | Should -Not -BeNullOrEmpty
                    $missingStep.with.project_file | Should -Not -BeNullOrEmpty
                    $missingStep.with.relative_path | Should -Not -BeNullOrEmpty
                    $artifactStep = $job.steps | Where-Object {
                        $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' -and (
                            ($_.with.name -match 'missing') -or ($_.with.path -match 'missing')
                        )
                    } | Select-Object -First 1
                    $artifactStep | Should -Not -BeNullOrEmpty
                }
            }
        }

        if (-not $workflowFound) {
            Set-ItResult -Skipped -Because 'No workflow found using missing-in-project action'
        }
    }
}
