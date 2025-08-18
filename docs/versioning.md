# Versioning Policy

The **OpenSourceActions** module and composite action follow [Semantic Versioning](https://semver.org/) in the format **MAJOR.MINOR.PATCH**. The version is stored in `OpenSourceActions.psd1` and mirrored in repository tags.

## MAJOR version

Used for incompatible changes such as removing or renaming actions, changing required inputs, or altering behavior in a way that breaks existing workflows.

## MINOR version

Introduces backwards-compatible features: new adapters, optional parameters, or enhancements that do not require workflow changes.

## PATCH version

Reserved for backwards-compatible bug fixes and internal improvements.

## Updating Version in `OpenSourceActions.psd1`

```powershell
ModuleVersion = '1.2.3'
```

After updating the manifest:

1. Document the change in release notes.
2. Tag the repository with the new version.

## Maintaining Compatibility

- Preserve existing parameters where possible.
- Deprecate before removing features.
- Use `DryRun` and clear error messages to aid migrations.

## Examples of Changes and Their Impact

- Adding a new action adapter → **MINOR** bump.
- Requiring a previously optional parameter → **MAJOR** bump.
- Fixing a parsing bug without interface changes → **PATCH** bump.
- Renaming an action (`set-development-mode` → `enter-dev-mode`) → **MAJOR** bump.

## Communication

Release notes, README badges, and migration guides help users understand the impact of version changes and how to update their workflows.

Significant documentation revisions are tracked in [CHANGELOG.md](CHANGELOG.md). When you add or modify major documentation sections, append a dated entry or associated release version to keep the changelog current.
