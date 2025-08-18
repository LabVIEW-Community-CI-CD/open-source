#requires -Version 7.0
# Pester tests verifying dispatcher argument inputs and precedence.
# Requirement: REQ-000 - Dispatcher merges argument sources and warns on unknown parameters.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$global:dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'Dispatcher Args Inputs' {
    $meta = @{
        requirement = 'REQ-000'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/Dispatcher.ArgsInputs.Tests.ps1'
    }

    It 'accepts ArgsJson and warns on unknown parameters' -Tag 'REQ-000' {
        $params = Get-LabVIEWIconEditorArgsJson
        $projectRoot = $params.WorkingDirectory

        $json = @{
            MinimumSupportedLVVersion = '2021'
            SupportedBitness          = '64'
            Extra                     = 'value'
        } | ConvertTo-Json -Compress

        $out = & $global:dispatcher -ActionName close-labview -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match '"SupportedBitness":"64"'
        $out | Should -Match "Ignored unknown parameters for 'close-labview': Extra"
    }

    It 'accepts ArgsFile and warns on unknown parameters' -Tag 'REQ-000' {
        $params = Get-LabVIEWIconEditorArgsJson
        $projectRoot = $params.WorkingDirectory

        $jsonFile = Join-Path $TestDrive 'args.json'
        @{ MinimumSupportedLVVersion = '2021'; SupportedBitness = '64'; Extra = 'value' } |
            ConvertTo-Json -Compress | Set-Content -Path $jsonFile

        $out = & $global:dispatcher -ActionName close-labview -ArgsFile $jsonFile -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match '"SupportedBitness":"64"'
        $out | Should -Match "Ignored unknown parameters for 'close-labview': Extra"
    }

    It 'uses inline args to override file and warns on all unknown parameters' -Tag 'REQ-000' {
        $params = Get-LabVIEWIconEditorArgsJson
        $projectRoot = $params.WorkingDirectory

        $file = Join-Path $TestDrive 'args.json'
        @{ MinimumSupportedLVVersion = '2021'; SupportedBitness = '32'; FileExtra = 1 } |
            ConvertTo-Json -Compress | Set-Content -Path $file

        $json = @{ SupportedBitness = '64'; JsonExtra = 2 } | ConvertTo-Json -Compress
        $table = @{ MinimumSupportedLVVersion = '2019'; TableExtra = 3 }

        $out = & $global:dispatcher -ActionName close-labview -ArgsFile $file -ArgsJson $json -ArgsHashtable $table -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match '"MinimumSupportedLVVersion":"2019"'
        $out | Should -Match '"SupportedBitness":"64"'
        $out | Should -Match 'Ignored unknown parameters'
        $out | Should -Match 'FileExtra'
        $out | Should -Match 'JsonExtra'
        $out | Should -Match 'TableExtra'
    }
}

