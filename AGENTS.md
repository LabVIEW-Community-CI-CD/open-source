# AGENTS.md

## Environment Setup
- Run `apt-get update && apt-get install -y apt-utils` to ensure required APT utilities are available.
- Ensure Node.js 24 or newer is installed (e.g. via the NodeSource setup script).
- Install `actionlint` and ensure it is on your `PATH`:
  - `go install github.com/rhysd/actionlint/cmd/actionlint@latest`
- Ensure PowerShell 7.5.1 is installed and accessible.

## Testing
- Run `npm run check:node` to verify Node.js satisfies the required version.
- Run `npm install` to ensure Node dependencies are available.
- Run `npm test`.
- Run `npm run lint:md` to lint Markdown files.
- Run `npx --yes markdown-link-check -q -c .markdown-link-check.json README.md $(find docs scripts -name '*.md')` to verify links.
- Run `actionlint` to validate GitHub Actions workflows.
- Run `pwsh -NoLogo -Command "$cfg = New-PesterConfiguration; $cfg.Run.Path = './tests/pester'; $cfg.TestResult.Enabled = $false; Invoke-Pester -Configuration $cfg"` and ensure all tests pass (XML output is intentionally disabled).
