# Contributing

Contributions of all kinds are welcome. Before submitting pull requests, run the JavaScript tests and any available linters.

```bash
npm test
```

For documentation updates, follow the [documentation contribution guidelines](docs/contributing-docs.md). Run the following to lint Markdown files and verify links before submitting a pull request:

```bash
npx --yes markdownlint-cli README.md docs/**/*.md doc-templates/**/*.md scripts/**/*.md
npx --yes markdown-link-check -q -c .markdown-link-check.json README.md $(find docs doc-templates scripts -name '*.md')
```
