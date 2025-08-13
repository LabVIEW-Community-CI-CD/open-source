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

Write-Host 'Running markdown-link-check...'
# Check links in README
npx --yes markdown-link-check -q -c .markdown-link-check.json README.md

# Check links in docs
Get-ChildItem -Path 'docs' -Recurse -Filter '*.md' | ForEach-Object {
    npx --yes markdown-link-check -q -c .markdown-link-check.json $_.FullName
}
