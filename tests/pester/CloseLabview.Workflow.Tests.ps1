#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'CloseLabview.Workflow' {
    $meta = @{
        requirement = 'REQ-012'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/CloseLabview.Workflow.Tests.ps1'
    }

    It 'runs close-labview action for 32-bit and 64-bit and uploads logs' -Tag 'REQ-012' {
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
                $job.'runs-on' | Should -Be 'ubuntu-latest'
                $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
                $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }
                $checkoutSteps.Count | Should -Be 1
                $externalCheckout | Should -BeNullOrEmpty

                $bitness = $closeSteps | ForEach-Object { $_.with.supported_bitness }
                $bitness | Should -Contain '32'
                $bitness | Should -Contain '64'

                foreach ($step in $closeSteps) {
                    $step.with.working_directory | Should -Be '${{ github.workspace }}/scripts/close-labview'
                }

                $logUploadSteps = $job.steps | Where-Object {
                    $_.uses -like 'actions/upload-artifact@*' -and (
                        ($_.with.path -match '\.log$') -or ($_.with.name -match '\.log$')
                    )
                }
                $logUploadSteps | Should -HaveCount 2
                $logUploadSteps | ForEach-Object { $_.with.path | Should -Be '${{ github.workspace }}/scripts/close-labview/close-labview.log' }
            }
        }

        if (-not $jobFound) {
            Set-ItResult -Failed -Because 'No steps found using close-labview action in close-labview-external.yml'
        }
    }
}
