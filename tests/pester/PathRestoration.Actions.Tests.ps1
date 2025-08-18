#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
Import-Module (Join-Path $repoRoot 'actions' 'OpenSourceActions.psm1') -Force

Describe 'Adapters restore PATH' -Skip {
    $meta = @{
        requirement = 'REQ-000'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/PathRestoration.Actions.Tests.ps1'
    }

    BeforeAll {
        $script:gcliPath = Join-Path $PSScriptRoot 'dummy-gcli'
        New-Item -ItemType Directory -Path $script:gcliPath -Force | Out-Null
    }
    AfterAll {
        Remove-Item -Path $script:gcliPath -Recurse -Force -ErrorAction SilentlyContinue
    }

    $cases = @(
        @{ Func='Invoke-AddTokenToLabVIEW'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','add-token-to-labview','AddTokenToLabVIEW.ps1'); Args=@{ MinimumSupportedLVVersion='2021'; SupportedBitness='64'; RelativePath='.' } },
        @{ Func='Invoke-ApplyVIPC'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','apply-vipc','ApplyVIPC.ps1'); Args=@{ MinimumSupportedLVVersion='2021'; VIP_LVVersion='2021'; SupportedBitness='64'; RelativePath='.'; VIPCPath='dummy.vipc' } },
        @{ Func='Invoke-BuildViPackage'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','build-vi-package','build_vip.ps1'); Args=@{ MinimumSupportedLVVersion='2021'; SupportedBitness='64'; LabVIEWMinorRevision='2021'; RelativePath='.'; VIPBPath='dummy.vipb'; Major=1; Minor=0; Patch=0; Build=1; Commit='abc'; DisplayInformationJSON='{}' } },
        @{ Func='Invoke-Build'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','build','Build.ps1'); Args=@{ RelativePath='.'; Major=1; Minor=0; Patch=0; Build=1; Commit='abc'; LabVIEWMinorRevision='2021'; CompanyName='Co'; AuthorName='Auth' } },
        @{ Func='Invoke-BuildLvlibp'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','build-lvlibp','Build_lvlibp.ps1'); Args=@{ MinimumSupportedLVVersion='2021'; SupportedBitness='64'; RelativePath='.'; LabVIEW_Project='Proj'; Build_Spec='Spec'; Major=1; Minor=0; Patch=0; Build=1; Commit='abc' } },
        @{ Func='Invoke-CloseLabVIEW'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','close-labview','Close_LabVIEW.ps1'); Args=@{ MinimumSupportedLVVersion='2021'; SupportedBitness='64' } },
        @{ Func='Invoke-GenerateReleaseNotes'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','generate-release-notes','GenerateReleaseNotes.ps1'); Args=@{ OutputPath='notes.md' } },
        @{ Func='Invoke-MissingInProject'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','missing-in-project','Invoke-MissingInProjectCLI.ps1'); Args=@{ LVVersion='2021'; Arch='64'; ProjectFile='Proj.lvproj' } },
        @{ Func='Invoke-ModifyVIPBDisplayInfo'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','modify-vipb-display-info','ModifyVIPBDisplayInfo.ps1'); Args=@{ SupportedBitness='64'; RelativePath='.'; VIPBPath='dummy.vipb'; MinimumSupportedLVVersion='2021'; LabVIEWMinorRevision='2021'; Major=1; Minor=0; Patch=0; Build=1; Commit='abc'; DisplayInformationJSON='{}' } },
        @{ Func='Invoke-PrepareLabVIEWSource'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','prepare-labview-source','Prepare_LabVIEW_source.ps1'); Args=@{ MinimumSupportedLVVersion='2021'; SupportedBitness='64'; RelativePath='.'; LabVIEW_Project='Proj'; Build_Spec='Spec' } },
        @{ Func='Invoke-RenameFile'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','rename-file','Rename-file.ps1'); Args=@{ CurrentFilename='a'; NewFilename='b' } },
        @{ Func='Invoke-RestoreSetupLVSource'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','restore-setup-lv-source','RestoreSetupLVSource.ps1'); Args=@{ MinimumSupportedLVVersion='2021'; SupportedBitness='64'; RelativePath='.'; LabVIEW_Project='Proj'; Build_Spec='Spec' } },
        @{ Func='Invoke-RevertDevelopmentMode'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','revert-development-mode','RevertDevelopmentMode.ps1'); Args=@{ RelativePath='.' } },
        @{ Func='Invoke-RunUnitTests'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','run-unit-tests','RunUnitTests.ps1'); Args=@{ MinimumSupportedLVVersion='2021'; SupportedBitness='64' } },
        @{ Func='Invoke-SetDevelopmentMode'; Script=[System.IO.Path]::Combine($repoRoot,'scripts','set-development-mode','Set_Development_Mode.ps1'); Args=@{ RelativePath='.' } }
    )

    foreach ($case in $cases) {
        $caseCopy = $case
        It "restores PATH after $($caseCopy.Func)" {
            $originalPath = $env:PATH
            & $caseCopy.Func @($caseCopy.Args) -DryRun -gcliPath $script:gcliPath | Out-Null
            $env:PATH | Should -Be $originalPath
        }
    }
}

