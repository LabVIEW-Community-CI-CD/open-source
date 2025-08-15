# AGENTS.md

## Testing
- Run `npm install` to ensure Node dependencies are available.
- Run `npm test`.
- Run `pwsh scripts/lint-docs.ps1` to lint Markdown files and verify links.
- Run `pwsh -NoLogo -Command "Invoke-Pester -CI -Path ./tests/pester"`.

All tests above are mandatory; they must pass before committing.

## Notes
- Use a single commit; do not create new branches.
