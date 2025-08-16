# AGENTS.md

## Testing
- Run `npm run check:node` to verify Node.js satisfies the required version.
- Run `npm install` to ensure Node dependencies are available.
- Run `npm test`.
- Run `npx --yes markdownlint-cli README.md docs/**/*.md scripts/**/*.md` to lint Markdown files.
- Run `npx --yes markdown-link-check -q -c .markdown-link-check.json README.md $(find docs scripts -name '*.md')` to verify links.
- Run `npx --yes actionlint` to validate GitHub Actions workflows.
- Ensure PowerShell 7.5.2 is installed.
- Run `pwsh -NoLogo -Command "Install-Module -Name Pester,powershell-yaml -Force -Scope AllUsers; Invoke-Pester -CI -Path ./tests/pester"`.

All tests above are mandatory; they must pass before committing.

## Notes
- Use a single commit; do not create new branches.
