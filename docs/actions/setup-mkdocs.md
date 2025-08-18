# setup-mkdocs

## Purpose

Install a pinned MkDocs with caching.

## Parameters

None.

## GitHub Action inputs

This action has no inputs.

## GitHub Action example

```yaml
- name: Setup MkDocs
  uses: LabVIEW-Community-CI-CD/open-source-actions/setup-mkdocs@v1
```

## Return Codes

- `0` – MkDocs installed
- non‑zero – install failed

See [setup-mkdocs/action.yml](../../setup-mkdocs/action.yml) for implementation details.

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).
