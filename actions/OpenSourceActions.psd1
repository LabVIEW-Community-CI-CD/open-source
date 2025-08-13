@{
  RootModule            = 'OpenSourceActions.psm1'
  ModuleVersion         = '1.0.0'
  GUID                  = '8c0a64c5-6a52-4d7e-9f74-8f79f21f1b2c'
  Author                = 'LabVIEW Community CI/CD'
  CompanyName           = 'LabVIEW Community'
  Copyright             = '(c) 2025 LabVIEW Community'
  Description           = 'Unified dispatcher adapters for open-source-actions'
  PowerShellVersion     = '7.0'
  CompatiblePSEditions  = @('Core')

  FunctionsToExport = @(
    'InvokeAddTokenToLabVIEW'
    'InvokeApplyVIPC'
    'InvokeBuild'
    'InvokeBuildLvlibp'
    'InvokeBuildViPackage'
    'InvokeCloseLabVIEW'
    'InvokeGenerateReleaseNotes'
    'InvokeMissingInProject'
    'InvokeModifyVIPBDisplayInfo'
    'InvokePrepareLabVIEWSource'
    'InvokeRenameFile'
    'InvokeRestoreSetupLVSource'
    'InvokeRevertDevelopmentMode'
    'InvokeRunUnitTests'
    'InvokeSetDevelopmentMode'
  )

  PrivateData = @{
    PSData = @{
      ReleaseNotes = @(
        '1.0.0 - Initial release: adapters for apply-vipc, build-lvlibp, missing-in-project, run-unit-tests; Format-UnitTestReport helper; discovery flags; DryRun; cross-platform g-cli support.'
      )
    }
  }
}
