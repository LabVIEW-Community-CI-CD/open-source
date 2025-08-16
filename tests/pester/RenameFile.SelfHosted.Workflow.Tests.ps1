#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module powershell-yaml

Describe 'RenameFile.SelfHosted.Workflow [REQ-011]' {
    It 'runs rename-file action on a self-hosted runner and uploads renamed file artifact [REQ-011]' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $wfDir = Join-Path $repoRoot '.github/workflows'
        $workflowFiles = Get-ChildItem -Path $wfDir -Filter '*.yml'
        $workflowFound = $false

        foreach ($wfFile in $workflowFiles) {
            $wf = Get-Content -Raw $wfFile.FullName | ConvertFrom-Yaml
            foreach ($jobEntry in $wf.jobs.GetEnumerator()) {
                $job = $jobEntry.Value
                $renameStep = $job.steps | Where-Object { $_.uses -eq './rename-file/action.yml' } | Select-Object -First 1
                if ($null -ne $renameStep) {
                    $workflowFound = $true

                    $job.'runs-on' | Should -Be @('self-hosted','icon-editor-windows')
                    $renameStep.uses | Should -Be './rename-file/action.yml'
                    $renameStep.with.current_filename | Should -Not -BeNullOrEmpty
                    $renameStep.with.new_filename | Should -Not -BeNullOrEmpty

                    $newFilename = $renameStep.with.new_filename
                    $escaped = [regex]::Escape($newFilename)
                    $uploadStep = $job.steps | Where-Object {
                        $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' -and (
                            ($_.with.name -match $escaped) -or ($_.with.path -match $escaped)
                        )
                    } | Select-Object -First 1
                    $uploadStep | Should -Not -BeNullOrEmpty
                }
            }
        }

        if (-not $workflowFound) {
            Set-ItResult -Skipped -Because 'No workflow found using rename-file action'
        }
    }
}
