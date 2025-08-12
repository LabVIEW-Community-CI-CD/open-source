# Open Source LabVIEW Actions

Unifies LabVIEW CI/CD scripts behind a single PowerShell dispatcher. Use `Invoke-OSAction.ps1` to call actions by name with JSON arguments. The dispatcher exposes discovery commands (`-ListActions` and `-Describe`) and preserves each action's exit codes. It runs on Windows or Linux runners with LabVIEW and g-cli available, and supports `-DryRun` for safe previews.

## Get Started

- [Architecture](architecture.md)
- [Quickstart](quickstart.md)
- [Common Parameters](common-parameters.md)
- [Adapter Authoring Guide](adapter-authoring.md)
- [Versioning Policy](versioning.md)
- [Documentation Changelog](CHANGELOG.md)

## Action Reference

- [add-token-to-labview](actions/add-token-to-labview.md)
- [apply-vipc](actions/apply-vipc.md)
- [build](actions/build.md)
- [build-lvlibp](actions/build-lvlibp.md)
- [build-vi-package](actions/build-vi-package.md)
- [close-labview](actions/close-labview.md)
- [generate-release-notes](actions/generate-release-notes.md)
- [missing-in-project](actions/missing-in-project.md)
- [modify-vipb-display-info](actions/modify-vipb-display-info.md)
- [prepare-labview-source](actions/prepare-labview-source.md)
- [rename-file](actions/rename-file.md)
- [restore-setup-lv-source](actions/restore-setup-lv-source.md)
- [revert-development-mode](actions/revert-development-mode.md)
- [run-unit-tests](actions/run-unit-tests.md)
- [set-development-mode](actions/set-development-mode.md)
