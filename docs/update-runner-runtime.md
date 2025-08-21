# Update Runner Runtime Workflow

This guide walks administrators through updating runner metadata without opening a pull request. The [`update-runner-runtime.yml`](../.github/workflows/update-runner-runtime.yml) workflow edits the `requirements*.json` files and pushes the change to the default branch.

## Triggering the workflow

1. In the repository on GitHub, open the **Actions** tab.
2. Select **Update Runner Runtime**.
3. Choose **Run workflow**.
4. Provide the required inputs and click **Run workflow**.

The job runs on a GitHub-hosted Ubuntu runner.

## Inputs

| Name | Description | Example |
| ---- | ----------- | ------- |
| `runner_key` | Key of the runner entry in `requirements*.json`. | `self-hosted-windows-lv-integration` |
| `runner_label` | Value for `runner_label`. Leave blank to keep the current label. | `self-hosted-windows-lv` |
| `runner_type` | Value for `runner_type`, such as `standard` or `integration`. | `integration` |
| `skip_dry_run` | `true` to set `skip_dry_run`, `false` to clear it. | `true` |

All inputs are strings; omit an input to leave the field unchanged.

## Expected output

`scripts/update-runner-runtime.js` updates every requirements file containing `runner_key` and prints the list of files it touched, for example:

```text
Updated requirements.json
Updated requirements-core.json
```

The workflow commits these files with the message `chore: update runner runtime for <runner_key>` using the repository's `GITHUB_TOKEN` and pushes directly to the default branch.

If the updated values match the existing file contents, the commit step logs `No changes to commit` and nothing is pushed.

## Common errors and troubleshooting

| Error | Explanation | Resolution |
| ----- | ----------- | ---------- |
| `Runner <key> not found` | No requirements file contains the supplied `runner_key`. | Verify the key against `requirements*.json` and try again. |
| `No changes to commit` | The inputs match the current values. | Provide different values or confirm the update already exists. |
| Permission denied | The workflow lacks write permission. | Ensure `GITHUB_TOKEN` has `contents: write` and that you have access to run the workflow. |

If the workflow fails, open the job logs to inspect the `Update requirements` step for details.
