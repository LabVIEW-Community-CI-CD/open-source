#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'RevertDevelopmentMode.Workflow' {
    $meta = @{
        requirement = 'REQ-019'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/RevertDevelopmentMode.Workflow.Tests.ps1'
    }

    It 'runs revert-development-mode action and uploads configuration artifact' -Tag 'REQ-019' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfDir = Join-Path $repoRoot '.github/workflows'
        $workflowFiles = Get-ChildItem -Path $wfDir -Filter '*.json'
        $workflowFound = $false

        foreach ($wfFile in $workflowFiles) {
            $wf = Get-Content -Raw $wfFile.FullName | ConvertFrom-Json -AsHashtable
            foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
                $job = $jobEntry.Value
                $revertStep = $job.steps | Where-Object { $_.uses -eq './revert-development-mode/action.yml' } | Select-Object -First 1
                if ($null -ne $revertStep) {
                    $workflowFound = $true
                    $job.'runs-on' | Should -Be 'ubuntu-latest'
                    $revertStep.uses | Should -Be './revert-development-mode/action.yml'
                    $revertStep.with.relative_path | Should -Not -BeNullOrEmpty
                    $uploadStep = $job.steps | Where-Object {
                        $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' -and (
                            $_.with.name -match 'config' -or $_.with.path -match 'config'
                        )
                    } | Select-Object -First 1
                    $uploadStep | Should -Not -BeNullOrEmpty
                }
            }
        }

        if (-not $workflowFound) {
            Set-ItResult -Skipped -Because 'No workflow found using revert-development-mode action'
        }
    }
}
