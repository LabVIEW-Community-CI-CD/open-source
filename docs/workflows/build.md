# build workflow

## Purpose

Dispatch the [build](../actions/build.md) action to a target repository through `Invoke-OSAction.ps1`.

## Parameters

### Inputs

| Parameter | Description |
| --- | --- |
| `repository` | Repository in `owner/repo` format to operate on. |
| `ref` | Branch or tag to check out. Defaults to `main`. |

### Secrets

| Secret | Description |
| --- | --- |
| `REPO_TOKEN` | Personal access token with permission to read the target repository. |

## Examples

```yaml
name: build
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
  build:
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
      - name: Run build
        shell: pwsh
        run: ./actions/Invoke-OSAction.ps1 -ActionName build -WorkingDirectory "${{ github.workspace }}/target"
```

## Return Codes

- N/A

## See also

- [Action documentation](../actions/build.md)
