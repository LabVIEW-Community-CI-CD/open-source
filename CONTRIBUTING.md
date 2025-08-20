# Contributing

Contributions of all kinds are welcome. Ensure you have Node.js 24 or newer installed, then run `npm install` to set up dependencies. Before submitting pull requests, run the JavaScript tests and any available linters.

```bash
npm install
npm run test:ci
npm run derive:registry
TEST_RESULTS_GLOBS='test-results/*junit*.xml' npm run generate:summary
npm run check:traceability
```

`npm run test:ci` writes JUnit files to `test-results/`. Commit `test-results/*` and `artifacts/linux/*` along with your source changes.

For documentation updates, follow the [documentation contribution guidelines](docs/contributing-docs.md). Run the following to lint Markdown files and verify links before submitting a pull request:

```bash
npm run lint:md
npx --yes linkinator README.md docs scripts --config linkinator.config.json
```

## Requirement Traceability

Each requirement is tracked as an issue or entry in `requirements.json`. Whenever
you introduce a new feature or fix, add a new requirement or update an existing
ID in `requirements.json` accordingly. Every code change must reference the
requirement it addresses, and each requirement must be covered by at least one
automated test.

Embed the relevant requirement ID in new test cases; the testing framework
parses these annotations when generating the traceability report.

During code reviews, missing requirement IDs or missing tests for a change are
must-fix issues. The CI pipeline checks these links and reports missing
associations.

## Commit Messages

Each commit should reference at least one requirement ID defined in `requirements.json` (for example, `REQ-001`). Pull requests lacking requirement references or associated tests must be updated before merging.
