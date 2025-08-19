# missing-in-project workflow

## Purpose

Dispatch the [missing-in-project](../actions/missing-in-project.md) action to a target repository through `Invoke-OSAction.ps1`.

## Inputs

| Input | Description |
| --- | --- |
| `repository` | Repository in `owner/repo` format to operate on. |
| `ref` | Branch or tag to check out. Defaults to `main`. |

## Required secrets

| Secret | Description |
| --- | --- |
| `REPO_TOKEN` | Personal access token with permission to read the target repository. |

## Example

```yaml
name: missing-in-project
on:
  workflow_dispatch:
    inputs:
      repository:
        description: 'owner/repo of the repository to target'
        required: true
      ref:
        description: 'Branch or tag to check out'
        required: false
        default: 'main'
jobs:
  missing-in-project:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Checkout target repository
        uses: actions/checkout@v4
        with:
          repository: ${{ inputs.repository }}
          ref: ${{ inputs.ref }}
          path: target
          token: ${{ secrets.REPO_TOKEN }}
      - name: Run missing-in-project
        shell: pwsh
        run: ./actions/Invoke-OSAction.ps1 -ActionName missing-in-project -WorkingDirectory "${{ github.workspace }}/target"
```
