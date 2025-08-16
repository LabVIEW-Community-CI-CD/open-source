# AGENTS.md

## Testing
- Run `npm install` to ensure Node dependencies are available.
- Run `npm test`.
- Run `npx --yes markdownlint-cli README.md docs/**/*.md doc-templates/**/*.md scripts/**/*.md` to lint Markdown files.
- Run `npx --yes markdown-link-check -q -c .markdown-link-check.json README.md $(find docs doc-templates scripts -name '*.md')` to verify links.
- Run `pwsh -NoLogo -Command "Invoke-Pester -CI -Path ./tests/pester"`.

All tests above are mandatory; they must pass before committing.

## Notes
- Use a single commit; do not create new branches.
