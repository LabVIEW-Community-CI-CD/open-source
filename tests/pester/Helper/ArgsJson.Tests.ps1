#requires -Version 7.0
# Requirement: REQ-007 - Helper derives LabVIEW icon editor arguments from environment.
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'ArgsJson.psm1')

Describe 'Get-LabVIEWIconEditorArgsJson' {
    $meta = @{
        requirement = 'REQ-007'
        Owner       = 'DevTools'
        Evidence    = 'tests/pester/Helper/ArgsJson.Tests.ps1'
    }

    It 'defaults to repo root when not requiring project [REQ-007]' -Tag 'REQ-007' {
        $orig = $env:LABVIEW_ICON_EDITOR_PATH
        try {
            Remove-Item Env:LABVIEW_ICON_EDITOR_PATH -ErrorAction SilentlyContinue
            $env:LABVIEW_ICON_EDITOR_REQUIRED = $null
            $params = Get-LabVIEWIconEditorArgsJson
            $expected = (Resolve-Path (Join-Path $PSScriptRoot '..' '..' '..')).Path
            $params.WorkingDirectory | Should -Be $expected
        }
        finally {
            if ($null -eq $orig) {
                Remove-Item Env:LABVIEW_ICON_EDITOR_PATH -ErrorAction SilentlyContinue
            } else {
                $env:LABVIEW_ICON_EDITOR_PATH = $orig
            }
            Remove-Item Env:LABVIEW_ICON_EDITOR_REQUIRED -ErrorAction SilentlyContinue
        }
    }

    It 'throws when LABVIEW_ICON_EDITOR_PATH is invalid [REQ-007]' -Tag 'REQ-007' {
        $orig = $env:LABVIEW_ICON_EDITOR_PATH
        try {
            $env:LABVIEW_ICON_EDITOR_PATH = Join-Path $PSScriptRoot 'NoSuchDir'
            $err = { Get-LabVIEWIconEditorArgsJson } | Should -Throw -PassThru
            $err.Exception.Message | Should -Match 'Clone.*LABVIEW_ICON_EDITOR_PATH'
        }
        finally {
            if ($null -eq $orig) {
                Remove-Item Env:LABVIEW_ICON_EDITOR_PATH -ErrorAction SilentlyContinue
            } else {
                $env:LABVIEW_ICON_EDITOR_PATH = $orig
            }
        }
    }
}
