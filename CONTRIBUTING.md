# Contributing

Contributions of all kinds are welcome. Ensure you have Node.js 24 or newer installed, then run `npm install` to set up dependencies. Before submitting pull requests, run the JavaScript tests and any available linters.

```bash
npm install
npm test
```

For documentation updates, follow the [documentation contribution guidelines](docs/contributing-docs.md). Run the following to lint Markdown files and verify links before submitting a pull request:

```bash
npm run lint:md
npx --yes markdown-link-check -q -c .markdown-link-check.json README.md $(find docs scripts -name '*.md')
```
