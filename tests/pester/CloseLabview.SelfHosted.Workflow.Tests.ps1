#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module powershell-yaml

Describe 'CloseLabview.SelfHosted.Workflow [REQ-012]' {
    It 'runs close-labview action for 32-bit and 64-bit and uploads logs [REQ-012]' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfDir = Join-Path $repoRoot '.github/workflows'
        $workflowFiles = Get-ChildItem -Path $wfDir -Filter '*.yml'
        $workflowFound = $false
        $found32 = $false
        $found64 = $false

        foreach ($wfFile in $workflowFiles) {
            $wf = Get-Content -Raw $wfFile.FullName | ConvertFrom-Yaml
            foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
                $job = $jobEntry.Value
                $closeSteps = $job.steps | Where-Object { $_.uses -eq './close-labview/action.yml' }
                if ($closeSteps) {
                    $workflowFound = $true
                    $job.'runs-on' | Should -Be @('self-hosted','self-hosted-windows-lv')
                    foreach ($step in $closeSteps) {
                        switch ($step.with.supported_bitness) {
                            '32' { $found32 = $true }
                            '64' { $found64 = $true }
                        }
                    }
                    $uploadStep = $job.steps | Where-Object {
                        $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' -and (
                            ($_.with.path -match '\.log$') -or ($_.with.name -match '\.log$')
                        )
                    } | Select-Object -First 1
                    $uploadStep | Should -Not -BeNullOrEmpty
                }
            }
        }

        if (-not $workflowFound) {
            Set-ItResult -Skipped -Because 'No workflow found using close-labview action'
        } else {
            $found32 | Should -BeTrue
            $found64 | Should -BeTrue
        }
    }
}
