#!/usr/bin/env pwsh
<##
.SYNOPSIS
Lint Markdown files and verify links.

.DESCRIPTION
Uses markdownlint to check formatting and markdown-link-check to verify hyperlinks in README and docs.
##>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host 'Running markdownlint...'
# Lint README and documentation Markdown files
npx --yes markdownlint-cli README.md docs/**/*.md
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Write-Host 'Running markdown-link-check...'
function Invoke-LinkCheck {
    param([string]$FilePath)

    $output = npx --yes markdown-link-check -q -c .markdown-link-check.json $FilePath 2>&1
    $output | Write-Output

    if ($output -match 'ERROR: \d+ dead links found') {
        Write-Error "Dead links found in $FilePath"
        return 1
    }
    if ($LASTEXITCODE -ne 0) {
        return $LASTEXITCODE
    }

    return 0
}

$exitCode = 0

if (Invoke-LinkCheck README.md) {
    $exitCode = 1
}

Get-ChildItem -Path 'docs' -Recurse -Filter '*.md' | ForEach-Object {
    if (Invoke-LinkCheck $_.FullName) {
        $exitCode = 1
    }
}

exit $exitCode
