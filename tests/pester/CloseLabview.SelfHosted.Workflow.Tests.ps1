#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module powershell-yaml

Describe 'CloseLabview.SelfHosted.Workflow [REQ-012]' {
    It 'runs close-labview action for 32-bit and 64-bit and uploads logs [REQ-012]' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfFile = Join-Path $repoRoot '.github/workflows/close-labview-external.yml'

        if (-not (Test-Path $wfFile)) {
            Set-ItResult -Skipped -Because 'close-labview-external workflow not found'
            return
        }

        $wf = Get-Content -Raw $wfFile | ConvertFrom-Yaml
        $jobFound = $false

        foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
            $job = $jobEntry.Value
            $closeSteps = $job.steps | Where-Object { $_.uses -eq './close-labview/action.yml' }
            if ($closeSteps) {
                $jobFound = $true
                $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
                $bitness = $closeSteps | ForEach-Object { $_.with.supported_bitness }
                $bitness | Should -Contain '32'
                $bitness | Should -Contain '64'

                $logUploadSteps = $job.steps | Where-Object {
                    $_.uses -like 'actions/upload-artifact@*' -and (
                        ($_.with.path -match '\.log$') -or ($_.with.name -match '\.log$')
                    )
                }
                $logUploadSteps | Should -HaveCount 2
            }
        }

        if (-not $jobFound) {
            Set-ItResult -Failed -Because 'No steps found using close-labview action in close-labview-external.yml'
        }
    }
}
