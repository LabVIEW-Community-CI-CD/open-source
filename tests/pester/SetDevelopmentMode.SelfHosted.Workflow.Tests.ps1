#requires -Version 7.0
$env:PSModulePath = (Join-Path $PSScriptRoot 'Modules') + [System.IO.Path]::PathSeparator + $env:PSModulePath
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'SetDevelopmentMode.SelfHosted.Workflow' {
    $meta = @{
        requirement = 'REQ-021'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/SetDevelopmentMode.SelfHosted.Workflow.Tests.ps1'
    }

    It 'runs set-development-mode action on a self-hosted runner and uploads logs' -Tag 'REQ-021' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfDir = Join-Path $repoRoot '.github/workflows'
        $workflowFiles = Get-ChildItem -Path $wfDir -Filter '*.yml'
        $workflowFound = $false

        foreach ($wfFile in $workflowFiles) {
            $wf = Get-Content -Raw $wfFile.FullName | ConvertFrom-Yaml
            foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
                $job = $jobEntry.Value
                $setStep = $job.steps | Where-Object { $_.uses -eq './set-development-mode/action.yml' } | Select-Object -First 1
                if ($null -ne $setStep) {
                    $workflowFound = $true
                    $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
                    $setStep.with.relative_path | Should -Match 'labview-icon-editor$'
                    $setStep.with.gcli_path | Should -Not -BeNullOrEmpty
                    $setStep.with.working_directory | Should -Not -BeNullOrEmpty
                    $setStep.with.log_level | Should -Not -BeNullOrEmpty
                    $setStep.with.dry_run | Should -Not -BeNullOrEmpty
                    $artifactStep = $job.steps | Where-Object {
                        $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' -and (
                            ($_.with.path -match 'log') -or ($_.with.path -match 'dev') -or
                            ($_.with.name -match 'log') -or ($_.with.name -match 'dev')
                        )
                    } | Select-Object -First 1
                    $artifactStep | Should -Not -BeNullOrEmpty
                }
            }
        }

        if (-not $workflowFound) {
            Set-ItResult -Skipped -Because 'No workflow found using set-development-mode action'
        }
    }
}
