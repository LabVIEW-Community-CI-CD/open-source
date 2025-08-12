# Open Source LabVIEW Actions

Unifies LabVIEW CI/CD scripts behind a single PowerShell dispatcher. Use `Invoke-OSAction.ps1` to call actions by name with JSON arguments. The dispatcher exposes discovery commands (`-ListActions` and `-Describe`) and preserves each action's exit codes. It runs on Windows or Linux runners with LabVIEW and g-cli available, and supports `-DryRun` for safe previews.

## Get Started

- [Architecture](architecture.md)
- [Quickstart](quickstart.md)
- [Adapter Authoring Guide](adapter-authoring.md)
- [Versioning Policy](versioning.md)
- [Documentation Changelog](CHANGELOG.md)

## Action Reference

- [apply-vipc](actions/apply-vipc.md)
- [build-lvlibp](actions/build-lvlibp.md)
- [missing-in-project](actions/missing-in-project.md)
- [run-unit-tests](actions/run-unit-tests.md)
