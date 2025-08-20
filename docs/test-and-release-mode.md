# Test and Release Mode

Committing build artifacts together with a `release.json` file enables the release pipeline. The `release.json` file supplies the JSON payload describing the release:

```json
{"major":1,"minor":0,"patch":2,"title":"Release title"}
```

Ensure the build artifacts are present (for example under `artifacts/`) and checked in alongside `release.json`. The `ci.yml` workflow runs first and, on success, hands off to `release.yml` to publish the release. See the [Maintainer Guide](maintainer-guide.md) for repository expectations.

## Requirement Traceability

Each requirement is tracked as an issue or entry in a requirement mapping file such as [`requirements-core.json`](../requirements-core.json) or [`requirements-icon-editor.json`](../requirements-icon-editor.json). Every code change must reference the requirement it addresses, and each requirement must have at least one automated test. The CI pipeline checks these links and reports missing associations. For full mappings of requirements to tests, see [docs/requirements-core.md](requirements-core.md) and [docs/requirements-icon-editor.md](requirements-icon-editor.md).

When generating summaries, provide the mapping files via the `REQ_MAPPING_FILE` environment variable. Multiple files can be supplied as a comma-separated list, for example:

```bash
REQ_MAPPING_FILE="requirements-core.json,requirements-icon-editor.json"
```

`npm run test:ci` writes JUnit files to `test-results/`. [`scripts/generate-ci-summary.ts`](../scripts/generate-ci-summary.ts) parses these results to build requirement traceability files in OS-specific subdirectories (e.g., `artifacts/windows`, `artifacts/linux`) based on the `RUNNER_OS` environment variable. Commit `test-results/*` and `artifacts/linux/*` along with your source changes. The summary script searches `artifacts/` by default; set `TEST_RESULTS_GLOBS` if your reports are elsewhere.
