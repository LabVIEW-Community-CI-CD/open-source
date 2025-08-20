# scripts

TypeScript and PowerShell helper scripts invoked by the GitHub Action wrappers.

`generate-ci-summary.ts` reads requirement mappings from the `REQ_MAPPING_FILE`
environment variable. Provide one or more JSON files separated by commas to
combine multiple requirement sets.
