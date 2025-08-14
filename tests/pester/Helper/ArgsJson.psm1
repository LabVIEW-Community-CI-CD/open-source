function Get-LabVIEWIconEditorArgsJson {
    [OutputType([string])]
    param()

    $args = @{
        MinimumSupportedLVVersion = '2021'
        SupportedBitness          = '64'
        RelativePath              = 'C:\labview-icon-editor'
    }

    return ($args | ConvertTo-Json -Compress)
}

Export-ModuleMember -Function Get-LabVIEWIconEditorArgsJson
