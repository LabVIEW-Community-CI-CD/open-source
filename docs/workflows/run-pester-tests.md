# run-pester-tests workflow

## Purpose

Run Pester tests in a target repository by dispatching the [`run-pester-tests`](../actions/run-pester-tests.md) action through `Invoke-OSAction.ps1`.

## Inputs

| Input | Description |
| --- | --- |
| `repository` | Repository in `owner/repo` format to test. |
| `ref` | Branch or tag to check out. Defaults to `main`. |

## Required secrets

| Secret | Description |
| --- | --- |
| `REPO_TOKEN` | Personal access token with permission to read the target repository. Used by `actions/checkout` when accessing another repository. |

## Example

```yaml
name: Run Pester tests

on:
  workflow_dispatch:
    inputs:
      repository:
        description: 'owner/repo of the repository to test'
        required: true
      ref:
        description: 'Branch or tag to check out'
        required: false
        default: 'main'

jobs:
  run-pester-tests:
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
      - name: Run Pester tests
        shell: pwsh
        run: ./actions/Invoke-OSAction.ps1 -ActionName run-pester-tests -WorkingDirectory "${{ github.workspace }}/target"
```
