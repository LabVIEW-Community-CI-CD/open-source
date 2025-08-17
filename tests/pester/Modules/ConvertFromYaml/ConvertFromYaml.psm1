function ConvertFrom-Yaml {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)][string]$Yaml
    )
    process {
        $json = $Yaml | node -e "const fs=require('fs'); const yaml=require('js-yaml'); const input=fs.readFileSync(0,'utf8'); process.stdout.write(JSON.stringify(yaml.load(input)));"
        $json | ConvertFrom-Json -AsHashtable
    }
}
Export-ModuleMember -Function ConvertFrom-Yaml
