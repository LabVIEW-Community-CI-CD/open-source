#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'RenameFile.Workflow' {
    $meta = @{
        requirement = 'REQ-017'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/RenameFile.Workflow.Tests.ps1'
    }

    It 'runs rename-file action and uploads renamed file artifact' -Tag 'REQ-017' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/rename-file-self-hosted.json'
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Json -AsHashtable
        $job = $wf.jobs.'rename-file'
        $renameStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq './rename-file/action.yml' } | Select-Object -First 1
        $uploadStep = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -like 'actions/upload-artifact@*' } | Select-Object -First 1
        $checkoutSteps = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq 'actions/checkout@v4' }
        $externalCheckout = $job.steps | Where-Object { $_.ContainsKey('with') -and $_['with'].ContainsKey('repository') }

        $job.'runs-on' | Should -Be 'ubuntu-latest'
        $checkoutSteps.Count | Should -Be 1
        $externalCheckout | Should -BeNullOrEmpty

        $renameStep.with.current_filename | Should -Be 'scripts/rename-file/README.md'
        $renameStep.with.new_filename | Should -Be 'scripts/rename-file/README-renamed.md'
        $uploadStep.with.path | Should -Be 'scripts/rename-file/README-renamed.md'
    }
}
