# setup-mkdocs

## Purpose

Install a pinned MkDocs with caching.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

None.

### Optional

None.

### GitHub Action inputs

This action has no inputs.

## Examples

### GitHub Action

```yaml
- name: Setup MkDocs
  uses: LabVIEW-Community-CI-CD/open-source/setup-mkdocs@v1
```

## Return Codes

- `0` – MkDocs installed
- non‑zero – install failed

See [setup-mkdocs/action.yml](../../setup-mkdocs/action.yml) for implementation details.

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

## See also

- [Workflow documentation](../workflows/setup-mkdocs.md)
