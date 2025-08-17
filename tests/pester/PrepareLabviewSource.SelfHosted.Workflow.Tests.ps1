#requires -Version 7.0
$env:PSModulePath = (Join-Path $PSScriptRoot 'Modules') + [System.IO.Path]::PathSeparator + $env:PSModulePath
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'PrepareLabviewSource.SelfHosted.Workflow' {
    $meta = @{
        requirement = 'REQ-011'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/PrepareLabviewSource.SelfHosted.Workflow.Tests.ps1'
    }

    It 'runs prepare-labview-source action and uploads prepared source artifact' -Tag 'REQ-011' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfDir = Join-Path $repoRoot '.github/workflows'
        $workflowFiles = Get-ChildItem -Path $wfDir -Filter '*.yml'
        $workflowFound = $false

        foreach ($wfFile in $workflowFiles) {
            $wf = Get-Content -Raw $wfFile.FullName | ConvertFrom-Yaml
            foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
                $job = $jobEntry.Value
                $prepareStep = $job.steps | Where-Object { $_.uses -eq './prepare-labview-source/action.yml' } | Select-Object -First 1
                if ($null -ne $prepareStep) {
                    $workflowFound = $true
                    $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
                    $prepareStep.uses | Should -Be './prepare-labview-source/action.yml'
                    $prepareStep.with.relative_path | Should -Match 'labview-icon-editor$'
                    $prepareStep.with.labview_project | Should -Match 'labview-icon-editor.*lv_icon.lvproj$'
                    $prepareStep.with.build_spec | Should -Be 'Editor Packed Library'
                    $artifactStep = $job.steps | Where-Object {
                        $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' -and (
                            ($_.with.path -match 'source' -and $_.with.path -match '\\.zip$') -or
                            ($_.with.name -match 'source')
                        )
                    } | Select-Object -First 1
                    $artifactStep | Should -Not -BeNullOrEmpty
                }
            }
        }

        if (-not $workflowFound) {
            Set-ItResult -Skipped -Because 'No workflow found using prepare-labview-source action'
        }
    }
}
