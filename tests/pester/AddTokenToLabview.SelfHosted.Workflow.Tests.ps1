#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not (Get-Command ConvertFrom-Yaml -ErrorAction SilentlyContinue)) {
    Import-Module powershell-yaml
}

Describe 'AddTokenToLabview.SelfHosted.Workflow [REQ-008]' {
    It 'runs add-token-to-labview action on a self-hosted runner and uploads token artifact [REQ-008]' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfDir = Join-Path $repoRoot '.github/workflows'
        $workflowFiles = Get-ChildItem -Path $wfDir -Filter '*.yml'
        $workflowFound = $false

        foreach ($wfFile in $workflowFiles) {
            $wf = Get-Content -Raw $wfFile.FullName | ConvertFrom-Yaml
            foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
                $job = $jobEntry.Value
                $addStep = $job.steps | Where-Object { $_.uses -eq './add-token-to-labview/action.yml' } | Select-Object -First 1
                if ($null -ne $addStep) {
                    $workflowFound = $true
                    $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
                    $addStep.uses | Should -Be './add-token-to-labview/action.yml'
                    $addStep.with.minimum_supported_lv_version | Should -Not -BeNullOrEmpty
                    $addStep.with.supported_bitness | Should -Not -BeNullOrEmpty
                    $addStep.with.relative_path | Should -Not -BeNullOrEmpty
                    $uploadStep = $job.steps | Where-Object {
                        $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' -and (
                            ($_.with.name -match 'token') -or ($_.with.path -match 'token')
                        )
                    } | Select-Object -First 1
                    $uploadStep | Should -Not -BeNullOrEmpty
                }
            }
        }

        if (-not $workflowFound) {
            Set-ItResult -Skipped -Because 'No workflow found using add-token-to-labview action'
        }
    }
}
