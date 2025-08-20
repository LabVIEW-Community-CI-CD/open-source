#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'BuildProfile1.IconEditor.ApplyVipc.Dispatcher' {
    $meta = @{
        requirement = 'REQIE-002'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/BuildProfile1.IconEditor.ApplyVipc.Dispatcher.Tests.ps1'
    }

    It 'invokes apply-vipc via dispatcher [REQIE-002]' -Tag 'REQIE-002' {
        $params = Get-LabVIEWIconEditorArgsJson
        $base = $params.ArgsJson | ConvertFrom-Json
        $vipcPath = Join-Path $repoRoot 'scripts' 'apply-vipc' 'runner_dependencies.vipc'
        $base | Add-Member VIP_LVVersion '2021'
        $base | Add-Member VIPCPath $vipcPath
        $json = $base | ConvertTo-Json -Compress
        $projectRoot = $params.WorkingDirectory
        $out = & $dispatcher -ActionName apply-vipc -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $out | Should -Match 'ApplyVIPC.ps1'
        $out | Should -Match [regex]::Escape('runner_dependencies.vipc')
        $out | Should -Match '"VIP_LVVersion":"2021"'
    }
}
