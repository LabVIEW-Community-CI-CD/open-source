#requires -Version 7.0
# Pester v5+ tests verifying RelativePath-consuming actions
# Requirement: REQ-003 - Actions correctly resolve and pass RelativePath arguments without warnings.

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot   = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
$dispatcher = Join-Path $repoRoot 'actions' 'Invoke-OSAction.ps1'
Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')

$meta = @{
    requirement = 'REQ-003'
    Owner       = 'DevTools'
    Evidence    = 'tests/pester/RelativePath.Actions.Tests.ps1'
}

Describe 'add-token-to-labview resolves RelativePath' {
    It 'dry-runs without warnings' -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $json = $params.ArgsJson
        $projectRoot = $params.WorkingDirectory
        $expected = ($json | ConvertFrom-Json).RelativePath
        $out = & $dispatcher -ActionName add-token-to-labview -ArgsJson $json -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $expected
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'apply-vipc resolves RelativePath' {
    It 'dry-runs without warnings'  -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $b = $params.ArgsJson | ConvertFrom-Json
        $projectRoot = $params.WorkingDirectory
        $args = @{ MinimumSupportedLVVersion = $b.MinimumSupportedLVVersion; SupportedBitness = $b.SupportedBitness; RelativePath = $b.RelativePath; VIP_LVVersion = '2021'; VIPCPath = 'dummy.vipc' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName apply-vipc -ArgsJson $args -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $b.RelativePath
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'build-vi-package resolves RelativePath' {
    It 'dry-runs without warnings'  -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $b = $params.ArgsJson | ConvertFrom-Json
        $projectRoot = $params.WorkingDirectory
        $args = @{ MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; SupportedBitness=$b.SupportedBitness; LabVIEWMinorRevision='2021'; RelativePath=$b.RelativePath; VIPBPath='dummy.vipb'; Major=1; Minor=0; Patch=0; Build=1; Commit='deadbeef'; DisplayInformationJSON='{}'; ReleaseNotesFile='notes.md' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName build-vi-package -ArgsJson $args -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $b.RelativePath
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'build resolves RelativePath' {
    It 'dry-runs without warnings'  -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $b = $params.ArgsJson | ConvertFrom-Json
        $projectRoot = $params.WorkingDirectory
        $args = @{ RelativePath=$b.RelativePath; Major=1; Minor=0; Patch=0; Build=1; Commit='deadbeef'; LabVIEWMinorRevision='2021'; CompanyName='Company'; AuthorName='Author' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName build -ArgsJson $args -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $b.RelativePath
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'build-lvlibp resolves RelativePath' {
    It 'dry-runs without warnings'  -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $b = $params.ArgsJson | ConvertFrom-Json
        $projectRoot = $params.WorkingDirectory
        $args = @{ MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; SupportedBitness=$b.SupportedBitness; RelativePath=$b.RelativePath; LabVIEW_Project='My.lvproj'; Build_Spec='MyBuild'; Major=1; Minor=0; Patch=0; Build=1; Commit='deadbeef' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName build-lvlibp -ArgsJson $args -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $b.RelativePath
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'modify-vipb-display-info resolves RelativePath' {
    It 'dry-runs without warnings'  -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $b = $params.ArgsJson | ConvertFrom-Json
        $projectRoot = $params.WorkingDirectory
        $args = @{ SupportedBitness=$b.SupportedBitness; RelativePath=$b.RelativePath; VIPBPath='dummy.vipb'; MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; LabVIEWMinorRevision='2021'; Major=1; Minor=0; Patch=0; Build=1; Commit='deadbeef'; DisplayInformationJSON='{}'; ReleaseNotesFile='notes.md' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName modify-vipb-display-info -ArgsJson $args -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $b.RelativePath
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'prepare-labview-source resolves RelativePath' {
    It 'dry-runs without warnings'  -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $b = $params.ArgsJson | ConvertFrom-Json
        $projectRoot = $params.WorkingDirectory
        $args = @{ MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; SupportedBitness=$b.SupportedBitness; RelativePath=$b.RelativePath; LabVIEW_Project='My.lvproj'; Build_Spec='MyBuild' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName prepare-labview-source -ArgsJson $args -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $b.RelativePath
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'restore-setup-lv-source resolves RelativePath' {
    It 'dry-runs without warnings'  -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $b = $params.ArgsJson | ConvertFrom-Json
        $projectRoot = $params.WorkingDirectory
        $args = @{ MinimumSupportedLVVersion=$b.MinimumSupportedLVVersion; SupportedBitness=$b.SupportedBitness; RelativePath=$b.RelativePath; LabVIEW_Project='My.lvproj'; Build_Spec='MyBuild' } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName restore-setup-lv-source -ArgsJson $args -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $b.RelativePath
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'revert-development-mode resolves RelativePath' {
    It 'dry-runs without warnings'  -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $b = $params.ArgsJson | ConvertFrom-Json
        $projectRoot = $params.WorkingDirectory
        $args = @{ RelativePath=$b.RelativePath } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName revert-development-mode -ArgsJson $args -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $b.RelativePath
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'set-development-mode resolves RelativePath' {
    It 'dry-runs without warnings'  -Tag 'REQ-003' {
        $params = Get-LabVIEWIconEditorArgsJson
        $b = $params.ArgsJson | ConvertFrom-Json
        $projectRoot = $params.WorkingDirectory
        $args = @{ RelativePath=$b.RelativePath } | ConvertTo-Json -Compress
        $out = & $dispatcher -ActionName set-development-mode -ArgsJson $args -WorkingDirectory $projectRoot -DryRun *>&1 | Out-String
        $LASTEXITCODE | Should -Be 0
        $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
        $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
        ($jsonText | ConvertFrom-Json).RelativePath | Should -Be $b.RelativePath
        $out | Should -Not -Match 'Ignored unknown parameters'
    }
}

Describe 'RelativePath "." resolves with varying working directories' {
    foreach ($subdir in @('docs', 'scripts', 'tests')) {
        It "dry-runs without warnings when WorkingDirectory is $subdir" -Tag 'REQ-003' {
            $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
            $workingDir = Join-Path $repoRoot $subdir
            $args = @{ RelativePath = '.' } | ConvertTo-Json -Compress
            $out = & $dispatcher -ActionName set-development-mode -ArgsJson $args -WorkingDirectory $workingDir -DryRun *>&1 | Out-String
            $LASTEXITCODE | Should -Be 0
            $jsonLine = $out -split "`n" | Where-Object { $_ -match '{' } | Select-Object -Last 1
            $jsonText = $jsonLine -replace '^[^{}]*({.*})','$1'
            ($jsonText | ConvertFrom-Json).RelativePath | Should -Be '.'
            $resolved = [System.IO.Path]::TrimEndingDirectorySeparator((Resolve-Path (Join-Path $workingDir '.')).Path)
            $expected = [System.IO.Path]::TrimEndingDirectorySeparator((Resolve-Path $workingDir).Path)
            $resolved | Should -Be $expected
            $out | Should -Not -Match 'Ignored unknown parameters'
        }
    }
}

