#requires -Version 7.0
# Pester v5+ tests verifying RelativePath-consuming actions
# Requirement: REQ-003 - Actions correctly resolve and pass RelativePath arguments without warnings.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot   = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

Describe 'add-token-to-labview resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $json = Get-LabVIEWIconEditorArgsJson
        $out = & $dispatcher -ActionName add-token-to-labview -ArgsJson $json -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'apply-vipc resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $b = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
        $args = @{ MinimumSupportedLVVersion = $b.MinimumSupportedLVVersion; SupportedBitness = $b.SupportedBitness; RelativePath = $b.RelativePath; VIP_LVVersion = '2021'; VIPCPath = 'dummy.vipc' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName apply-vipc -ArgsJson $args -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'build-vi-package resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $b = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
        $args = @{ MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; SupportedBitness=$b.SupportedBitness; LabVIEWMinorRevision='2021'; RelativePath=$b.RelativePath; VIPBPath='dummy.vipb'; Major=1; Minor=0; Patch=0; Build=1; Commit='deadbeef'; DisplayInformationJSON='{}'; ReleaseNotesFile='notes.md' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName build-vi-package -ArgsJson $args -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'build resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $b = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
        $args = @{ RelativePath=$b.RelativePath; Major=1; Minor=0; Patch=0; Build=1; Commit='deadbeef'; LabVIEWMinorRevision='2021'; CompanyName='Company'; AuthorName='Author' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName build -ArgsJson $args -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'build-lvlibp resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $b = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
        $args = @{ MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; SupportedBitness=$b.SupportedBitness; RelativePath=$b.RelativePath; LabVIEW_Project='My.lvproj'; Build_Spec='MyBuild'; Major=1; Minor=0; Patch=0; Build=1; Commit='deadbeef' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName build-lvlibp -ArgsJson $args -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'modify-vipb-display-info resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $b = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
        $args = @{ SupportedBitness=$b.SupportedBitness; RelativePath=$b.RelativePath; VIPBPath='dummy.vipb'; MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; LabVIEWMinorRevision='2021'; Major=1; Minor=0; Patch=0; Build=1; Commit='deadbeef'; DisplayInformationJSON='{}'; ReleaseNotesFile='notes.md' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName modify-vipb-display-info -ArgsJson $args -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'prepare-labview-source resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $b = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
        $args = @{ MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; SupportedBitness=$b.SupportedBitness; RelativePath=$b.RelativePath; LabVIEW_Project='My.lvproj'; Build_Spec='MyBuild' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName prepare-labview-source -ArgsJson $args -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'restore-setup-lv-source resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $b = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
        $args = @{ MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; SupportedBitness=$b.SupportedBitness; RelativePath=$b.RelativePath; LabVIEW_Project='My.lvproj'; Build_Spec='MyBuild' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName restore-setup-lv-source -ArgsJson $args -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'revert-development-mode resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $b = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
        $args = @{ RelativePath=$b.RelativePath } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName revert-development-mode -ArgsJson $args -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'set-development-mode resolves RelativePath [REQ-003]' {
    It 'dry-runs without warnings [REQ-003]' {
        $b = Get-LabVIEWIconEditorArgsJson | ConvertFrom-Json
        $args = @{ RelativePath=$b.RelativePath } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName set-development-mode -ArgsJson $args -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be 'C:\labview-icon-editor'
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

