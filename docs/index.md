# Open Source LabVIEW Actions

Open Source LabVIEW Actions unifies LabVIEW CI/CD scripts behind a single PowerShell dispatcher. Most users should call the adapter-specific GitHub Actions (for example `run-unit-tests`) directly in workflows. The dispatcher script ([actions/Invoke-OSAction.ps1](../actions/Invoke-OSAction.ps1)) remains available for CLI scenarios. Adapter implementations live under [scripts/](../scripts), and each wrapper resides in its own folder at the repository root. Discovery commands (`-ListActions` and `-Describe`) and standard exit codes are preserved, and `-DryRun` is supported for safe previews on Windows or Linux runners with LabVIEW and g-cli available.

## Get Started

- [Architecture](architecture.md)
- [Quickstart](quickstart.md)
- [Action Call Reference](action-call-reference.md)
- [Common Parameters](common-parameters.md)
- [Adapter Authoring Guide](adapter-authoring.md)
- [Versioning Policy](versioning.md)
- [Documentation Changelog](CHANGELOG.md)

## Action Reference

| Action | Purpose |
| --- | --- |
| [add-token-to-labview](actions/add-token-to-labview.md) | Add a custom library path token to the LabVIEW INI file so LabVIEW can locate project libraries. |
| [apply-vipc](actions/apply-vipc.md) | Apply a VI Package Configuration (.vipc) file to a specific LabVIEW installation using g-cli. |
| [build](actions/build.md) | Automate building the LabVIEW Icon Editor project, including cleaning, building libraries, and packaging. |
| [build-lvlibp](actions/build-lvlibp.md) | Build a LabVIEW project’s build specification into a Packed Project Library (.lvlibp). |
| [build-vi-package](actions/build-vi-package.md) | Update VIPB display information and build a VI package using g-cli. |
| [close-labview](actions/close-labview.md) | Gracefully close a running LabVIEW instance via g-cli. |
| [generate-release-notes](actions/generate-release-notes.md) | Generate release notes from the git history and write them to a markdown file. |
| [missing-in-project](actions/missing-in-project.md) | Check that all files in a LabVIEW project are present by scanning for items missing from the `.lvproj`. |
| [modify-vipb-display-info](actions/modify-vipb-display-info.md) | Update display information in a VIPB file and rebuild the VI package. |
| [prepare-labview-source](actions/prepare-labview-source.md) | Run PrepareIESource.vi via g-cli to unzip components and configure LabVIEW for building. |
| [rename-file](actions/rename-file.md) | Rename a file if it exists. |
| [restore-setup-lv-source](actions/restore-setup-lv-source.md) | Restore the LabVIEW source setup by unzipping the LabVIEW Icon API and removing the INI token. |
| [revert-development-mode](actions/revert-development-mode.md) | Restore the repository from development mode by restoring packaged sources and closing LabVIEW. |
| [run-pester-tests](actions/run-pester-tests.md) | Run PowerShell Pester tests in a repository. |
| [run-unit-tests](actions/run-unit-tests.md) | Run LabVIEW unit tests via the LabVIEW Unit Test Framework CLI and report pass/fail/error using standard exit codes. |
| [set-development-mode](actions/set-development-mode.md) | Configure the repository for development mode by removing packed libraries, adding tokens, preparing sources, and closing LabVIEW. |
| [setup-mkdocs](actions/setup-mkdocs.md) | Install a pinned MkDocs with caching. |

## Workflow Examples

| Workflow | Purpose |
| --- | --- |
| [run-pester-tests](workflows/run-pester-tests.md) | Run Pester tests in a target repository. |
