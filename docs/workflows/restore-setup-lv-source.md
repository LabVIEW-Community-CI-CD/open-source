# restore-setup-lv-source workflow

## Purpose

Dispatch the [restore-setup-lv-source](../actions/restore-setup-lv-source.md) action to a target repository through `Invoke-OSAction.ps1`.

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
name: restore-setup-lv-source
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
  restore-setup-lv-source:
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
      - name: Run restore-setup-lv-source
        shell: pwsh
        run: ./actions/Invoke-OSAction.ps1 -ActionName restore-setup-lv-source -WorkingDirectory "${{ github.workspace }}/target"
```
