# Documentation Contribution Guidelines

To keep documentation consistent and easy to review, please follow these rules when editing or adding Markdown files.

## Action documentation

When adding a new action, copy [`doc-templates/action-doc-template.md`](../doc-templates/action-doc-template.md) to `docs/actions/<action-name>.md` and complete each section: Purpose, Parameters, CLI example, GitHub Action example, and Return Codes.

## Markdown linting

- Run `pwsh scripts/lint-docs.ps1` to lint Markdown and check links before submitting changes.
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
