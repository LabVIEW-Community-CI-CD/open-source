# Actions

List of available GitHub Actions.

- [add-token-to-labview](./add-token-to-labview.md): Add a custom library path token to the LabVIEW INI file so LabVIEW can locate project libraries.
- [apply-vipc](./apply-vipc.md): Apply a VI Package Configuration (.vipc) file to a specific LabVIEW installation using g-cli.
- [build-lvlibp](./build-lvlibp.md): Build a LabVIEW project’s build specification into a Packed Project Library (.lvlibp)
- [build-vi-package](./build-vi-package.md): Update VIPB display information and build a VI package using g-cli.
- [build](./build.md): Automate building the LabVIEW Icon Editor project, including cleaning, building libraries, and packaging.
- [close-labview](./close-labview.md): Gracefully close a running LabVIEW instance via g-cli.
- [generate-release-notes](./generate-release-notes.md): Generate release notes from the git history and write them to a markdown file.
- [missing-in-project](./missing-in-project.md): Check that all files in a LabVIEW project are present by scanning for items missing from the `.lvproj`.
- [modify-vipb-display-info](./modify-vipb-display-info.md): Update display information in a VIPB file and rebuild the VI package.
- [prepare-labview-source](./prepare-labview-source.md): Run PrepareIESource.vi via g-cli to unzip components and configure LabVIEW for building.
- [rename-file](./rename-file.md): Rename a file if it exists.
- [restore-setup-lv-source](./restore-setup-lv-source.md): Restore the LabVIEW source setup by unzipping the LabVIEW Icon API and removing the INI token.
- [revert-development-mode](./revert-development-mode.md): Restore the repository from development mode by restoring packaged sources and closing LabVIEW.
- [run-pester-tests](./run-pester-tests.md): Run PowerShell Pester tests in a repository.
- [run-unit-tests](./run-unit-tests.md): Run LabVIEW unit tests via the LabVIEW Unit Test Framework CLI and report pass/fail/error using standard exit codes.
- [set-development-mode](./set-development-mode.md): Configure the repository for development mode by removing packed libraries, adding tokens, preparing sources, and closing LabVIEW.
- [setup-mkdocs](./setup-mkdocs.md): Install a pinned MkDocs with caching.

## See also

- [Workflow documentation](../workflows/index.md)
