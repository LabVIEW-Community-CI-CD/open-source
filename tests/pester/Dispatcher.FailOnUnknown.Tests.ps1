#requires -Version 7.0
# Pester tests verifying dispatcher FailOnUnknown switch.
# Requirement: REQ-000 - Dispatcher merges argument sources and warns on unknown parameters.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$global:dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'Dispatcher FailOnUnknown' {
    $meta = @{
        requirement = 'REQ-000'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/Dispatcher.FailOnUnknown.Tests.ps1'
    }

    It 'warns on unknown parameters by default' -Tag 'REQ-000' {
        $params = Get-LabVIEWIconEditorArgsJson
        $json = @{ MinimumSupportedLVVersion = '2021'; SupportedBitness = '64'; Extra = 'value' } | ConvertTo-Json -Compress
        $out = & $global:dispatcher -ActionName close-labview -ArgsJson $json -WorkingDirectory $params.WorkingDirectory -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match "Ignored unknown parameters for 'close-labview': Extra"
    }

    It 'throws on unknown parameters when FailOnUnknown is set' -Tag 'REQ-000' {
        $params = Get-LabVIEWIconEditorArgsJson
        $json = @{ MinimumSupportedLVVersion = '2021'; SupportedBitness = '64'; Extra = 'value' } | ConvertTo-Json -Compress
        { & $global:dispatcher -ActionName close-labview -ArgsJson $json -WorkingDirectory $params.WorkingDirectory -DryRun -FailOnUnknown } | Should -Throw "Ignored unknown parameters for 'close-labview': Extra"
    }
}
