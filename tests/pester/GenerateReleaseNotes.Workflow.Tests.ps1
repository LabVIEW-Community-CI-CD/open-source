#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Describe 'GenerateReleaseNotes.Workflow' {
    $meta = @{
        requirement = 'REQ-013'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/GenerateReleaseNotes.Workflow.Tests.ps1'
    }

    It 'runs generate-release-notes action [REQ-013]' -Tag 'REQ-013' {
        $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
        $workflowPath = Join-Path $repoRoot '.github/workflows/generate-release-notes-self-hosted.json'
        if (-not (Test-Path $workflowPath)) {
            Set-ItResult -Skipped -Because 'Workflow file not found'
            return
        }
        $wf = Get-Content -Raw $workflowPath | ConvertFrom-Json -AsHashtable
        $job = $wf.jobs.'generate-release-notes'
        $step = $job.steps | Where-Object { $_.ContainsKey('uses') -and $_.uses -eq './generate-release-notes/action.yml' } | Select-Object -First 1
        $step | Should -Not -BeNullOrEmpty
        $step.with.dry_run | Should -Be $true
    }
}

