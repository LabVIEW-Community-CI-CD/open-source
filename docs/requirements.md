# Requirements

This project tracks multiple requirement sets:

- [Core requirements](requirements-core.md) – mapped in [`requirements-core.json`](../requirements-core.json)
- [Icon editor requirements](requirements-icon-editor.md) – mapped in [`requirements-icon-editor.json`](../requirements-icon-editor.json)

Each page lists the requirements and associated tests for that set.
When generating CI summaries, specify one or more mapping files with the
`REQ_MAPPING_FILE` environment variable. Separate multiple files with commas,
for example:

```bash
REQ_MAPPING_FILE="requirements-core.json,requirements-icon-editor.json" npm run generate:summary
```
