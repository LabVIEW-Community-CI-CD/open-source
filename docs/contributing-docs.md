# Documentation Contribution Guidelines

To keep documentation consistent and easy to review, please follow these rules when editing or adding Markdown files.

## Action documentation

Action documentation lives under [docs/actions/](actions/). Keep these files in sync with their corresponding implementations in [scripts/](../scripts).

## Markdown linting

- Run `npx --yes markdownlint-cli README.md docs/**/*.md scripts/**/*.md` to lint Markdown formatting.
- Run `npx --yes markdown-link-check -q -c .markdown-link-check.json README.md $(find docs scripts -name '*.md')` to check links before submitting changes.
- Keep one `#`-level heading at the top of each file and increment heading levels sequentially; do not skip levels.

## Heading levels

- Use `#` for the document title, then `##`, `###`, and so on.
- Avoid jumping from a `##` heading directly to `####`.

## Code block conventions

- Use fenced code blocks with triple backticks.
- Specify the language for syntax highlighting (for example, use `\`\`\`powershell` to start a PowerShell block).
- Use `text` for blocks that show output rather than code.

## Linking requirements

- Use relative links for files within this repository.
- Provide descriptive link text instead of raw URLs.
- Check that external links resolve correctly.

## Spell and linter checks

- Run a spell checker or Markdown linter (if available) before opening a pull request to catch formatting and spelling issues early.

## Preview the docs locally

You can use [MkDocs](https://www.mkdocs.org/) to preview documentation changes on your machine.

1. Install MkDocs and the Material theme:

   ```bash
   pip install mkdocs mkdocs-material
   ```

2. Start a local server:

   ```bash
   mkdocs serve
   ```

MkDocs serves the site at <http://127.0.0.1:8000/> by default. The server automatically rebuilds when files change, so refresh the browser to see your latest edits.

## JUnit integration

The CI pipeline collects JUnit XML output from both Node and PowerShell tests. `scripts/generate-ci-summary.ts` parses these files to build the requirement traceability report. Use `npm run test:ci` to produce the Node JUnit report when verifying documentation updates.
