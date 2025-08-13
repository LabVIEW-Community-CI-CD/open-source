function InvokeAddTokenToLabVIEW {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $MinimumSupportedLVVersion,
        [Parameter(Mandatory)] [string] $SupportedBitness,
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing AddTokenToLabVIEW (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'add-token-to-labview/AddTokenToLabVIEW.ps1'
    $args = @{
        MinimumSupportedLVVersion = $MinimumSupportedLVVersion
        SupportedBitness          = $SupportedBitness
        RelativePath              = $RelativePath
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeApplyVIPC {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $MinimumSupportedLVVersion,
        [Parameter(Mandatory)] [string] $VIP_LVVersion,
        [Parameter(Mandatory)] [string] $SupportedBitness,
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter()] [string] $VIPCPath,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing ApplyVIPC (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'apply-vipc/ApplyVIPC.ps1'
    $args = @{
        MinimumSupportedLVVersion = $MinimumSupportedLVVersion
        VIP_LVVersion             = $VIP_LVVersion
        SupportedBitness          = $SupportedBitness
        RelativePath              = $RelativePath
        VIPCPath                  = $VIPCPath
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeBuildViPackage {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $MinimumSupportedLVVersion,
        [Parameter(Mandatory)] [string] $SupportedBitness,
        [Parameter(Mandatory)] [string] $LabVIEWMinorRevision,
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter(Mandatory)] [string] $VIPBPath,
        [Parameter(Mandatory)] [int] $Major,
        [Parameter(Mandatory)] [int] $Minor,
        [Parameter(Mandatory)] [int] $Patch,
        [Parameter(Mandatory)] [int] $Build,
        [Parameter(Mandatory)] [string] $Commit,
        [Parameter(Mandatory)] [string] $DisplayInformationJSON,
        [Parameter()] [string] $ReleaseNotesFile,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing BuildViPackage version $Major.$Minor.$Patch-$Build (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'build-vi-package/build_vip.ps1'
    $args = @{
        MinimumSupportedLVVersion = $MinimumSupportedLVVersion
        SupportedBitness          = $SupportedBitness
        LabVIEWMinorRevision      = $LabVIEWMinorRevision
        RelativePath              = $RelativePath
        VIPBPath                  = $VIPBPath
        Major                     = $Major
        Minor                     = $Minor
        Patch                     = $Patch
        Build                     = $Build
        Commit                    = $Commit
        DisplayInformationJSON    = $DisplayInformationJSON
        ReleaseNotesFile          = $ReleaseNotesFile
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeBuild {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter(Mandatory)] [int] $Major,
        [Parameter(Mandatory)] [int] $Minor,
        [Parameter(Mandatory)] [int] $Patch,
        [Parameter(Mandatory)] [int] $Build,
        [Parameter(Mandatory)] [string] $Commit,
        [Parameter(Mandatory)] [string] $LabVIEWMinorRevision,
        [Parameter(Mandatory)] [string] $CompanyName,
        [Parameter(Mandatory)] [string] $AuthorName,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing Build version $Major.$Minor.$Patch-$Build (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'build/Build.ps1'
    $args = @{
        RelativePath         = $RelativePath
        Major                = $Major
        Minor                = $Minor
        Patch                = $Patch
        Build                = $Build
        Commit               = $Commit
        LabVIEWMinorRevision = $LabVIEWMinorRevision
        CompanyName          = $CompanyName
        AuthorName           = $AuthorName
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeBuildLvlibp {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $MinimumSupportedLVVersion,
        [Parameter(Mandatory)] [string] $SupportedBitness,
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter(Mandatory)] [string] $LabVIEW_Project,
        [Parameter(Mandatory)] [string] $Build_Spec,
        [Parameter(Mandatory)] [int] $Major,
        [Parameter(Mandatory)] [int] $Minor,
        [Parameter(Mandatory)] [int] $Patch,
        [Parameter(Mandatory)] [int] $Build,
        [Parameter(Mandatory)] [string] $Commit,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing BuildLvlibp version $Major.$Minor.$Patch-$Build (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'build-lvlibp/Build_lvlibp.ps1'
    $args = @{
        MinimumSupportedLVVersion = $MinimumSupportedLVVersion
        SupportedBitness          = $SupportedBitness
        RelativePath              = $RelativePath
        LabVIEW_Project           = $LabVIEW_Project
        Build_Spec                = $Build_Spec
        Major                     = $Major
        Minor                     = $Minor
        Patch                     = $Patch
        Build                     = $Build
        Commit                    = $Commit
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeCloseLabVIEW {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $MinimumSupportedLVVersion,
        [Parameter(Mandatory)] [string] $SupportedBitness,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing CloseLabVIEW (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'close-labview/Close_LabVIEW.ps1'
    $args = @{
        MinimumSupportedLVVersion = $MinimumSupportedLVVersion
        SupportedBitness          = $SupportedBitness
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeGenerateReleaseNotes {
    [CmdletBinding()]
    param(
        [Parameter()] [string] $OutputPath = 'Tooling/deployment/release_notes.md',
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing GenerateReleaseNotes (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'generate-release-notes/GenerateReleaseNotes.ps1'
    $args = @{ OutputPath = $OutputPath }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeMissingInProject {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $LVVersion,
        [Parameter(Mandatory)] [string] $Arch,
        [Parameter(Mandatory)] [string] $ProjectFile,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing MissingInProject (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'missing-in-project/CheckMissingInProject.ps1'
    $args = @{
        LVVersion   = $LVVersion
        Arch        = $Arch
        ProjectFile = $ProjectFile
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeModifyVIPBDisplayInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $SupportedBitness,
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter(Mandatory)] [string] $VIPBPath,
        [Parameter(Mandatory)] [string] $MinimumSupportedLVVersion,
        [Parameter(Mandatory)] [string] $LabVIEWMinorRevision,
        [Parameter(Mandatory)] [int] $Major,
        [Parameter(Mandatory)] [int] $Minor,
        [Parameter(Mandatory)] [int] $Patch,
        [Parameter(Mandatory)] [int] $Build,
        [Parameter(Mandatory)] [string] $Commit,
        [Parameter(Mandatory)] [string] $DisplayInformationJSON,
        [Parameter()] [string] $ReleaseNotesFile,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing ModifyVIPBDisplayInfo (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'modify-vipb-display-info/ModifyVIPBDisplayInfo.ps1'
    $args = @{
        SupportedBitness       = $SupportedBitness
        RelativePath           = $RelativePath
        VIPBPath               = $VIPBPath
        MinimumSupportedLVVersion = $MinimumSupportedLVVersion
        LabVIEWMinorRevision   = $LabVIEWMinorRevision
        Major                  = $Major
        Minor                  = $Minor
        Patch                  = $Patch
        Build                  = $Build
        Commit                 = $Commit
        DisplayInformationJSON = $DisplayInformationJSON
        ReleaseNotesFile       = $ReleaseNotesFile
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokePrepareLabVIEWSource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $MinimumSupportedLVVersion,
        [Parameter(Mandatory)] [string] $SupportedBitness,
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter(Mandatory)] [string] $LabVIEW_Project,
        [Parameter(Mandatory)] [string] $Build_Spec,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing PrepareLabVIEWSource (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'prepare-labview-source/Prepare_LabVIEW_source.ps1'
    $args = @{
        MinimumSupportedLVVersion = $MinimumSupportedLVVersion
        SupportedBitness          = $SupportedBitness
        RelativePath              = $RelativePath
        LabVIEW_Project           = $LabVIEW_Project
        Build_Spec                = $Build_Spec
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeRenameFile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $CurrentFilename,
        [Parameter(Mandatory)] [string] $NewFilename,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing RenameFile (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'rename-file/Rename-file.ps1'
    $args = @{
        CurrentFilename = $CurrentFilename
        NewFilename     = $NewFilename
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeRestoreSetupLVSource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $MinimumSupportedLVVersion,
        [Parameter(Mandatory)] [string] $SupportedBitness,
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter(Mandatory)] [string] $LabVIEW_Project,
        [Parameter(Mandatory)] [string] $Build_Spec,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing RestoreSetupLVSource (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'restore-setup-lv-source/RestoreSetupLVSource.ps1'
    $args = @{
        MinimumSupportedLVVersion = $MinimumSupportedLVVersion
        SupportedBitness          = $SupportedBitness
        RelativePath              = $RelativePath
        LabVIEW_Project           = $LabVIEW_Project
        Build_Spec                = $Build_Spec
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeRevertDevelopmentMode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing RevertDevelopmentMode (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'revert-development-mode/RevertDevelopmentMode.ps1'
    $args = @{ RelativePath = $RelativePath }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeRunUnitTests {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $MinimumSupportedLVVersion,
        [Parameter(Mandatory)] [string] $SupportedBitness,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing RunUnitTests (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'run-unit-tests/RunUnitTests.ps1'
    $args = @{
        MinimumSupportedLVVersion = $MinimumSupportedLVVersion
        SupportedBitness          = $SupportedBitness
    }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}

function InvokeSetDevelopmentMode {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)] [string] $RelativePath,
        [Parameter()] [string] $LogLevel = 'INFO',
        [Parameter()] [switch] $DryRun,
        [Parameter()] [string] $gcliPath
    )
    Write-Information "Executing SetDevelopmentMode (DryRun=$DryRun)"
    $scriptPath = Join-Path $PSScriptRoot 'set-development-mode/Set_Development_Mode.ps1'
    $args = @{ RelativePath = $RelativePath }
    if ($DryRun) {
        Write-Information "DryRun: & $scriptPath $($args | ConvertTo-Json -Compress)"
        return 0
    }
    if ($gcliPath) {
        $env:PATH = "$gcliPath;$($env:PATH)"
    }
    & $scriptPath @args
    if (-not $?) { return 1 }
    return $LASTEXITCODE
}