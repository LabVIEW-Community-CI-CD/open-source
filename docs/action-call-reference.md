# Action Call Reference

Each adapter in this repository is available as its own GitHub Action. Call them using `uses: LabVIEW-Community-CI-CD/open-source-actions/<action>@v1` with the required inputs shown below. Refer to the linked documentation for full parameter details.

## add-token-to-labview

See [add-token-to-labview](actions/add-token-to-labview.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/add-token-to-labview@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    relative_path: '.'
```

## apply-vipc

See [apply-vipc](actions/apply-vipc.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/apply-vipc@v1
  with:
    minimum_supported_lv_version: '2019'
    vip_lv_version: '2019'
    supported_bitness: '64'
    relative_path: '.'
```

## build

See [build](actions/build.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/build@v1
  with:
    relative_path: '.'
    major: 1
    minor: 0
    patch: 0
    build: 1
    commit: abcdef
    labview_minor_revision: '3'
    company_name: 'Acme Corp'
    author_name: 'Jane Doe'
```

## build-lvlibp

See [build-lvlibp](actions/build-lvlibp.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/build-lvlibp@v1
  with:
    minimum_supported_lv_version: '2020'
    supported_bitness: '64'
    relative_path: '.'
    labview_project: 'Source/MyProject.lvproj'
    build_spec: 'PackedLib Build'
    major: 1
    minor: 0
    patch: 0
    build: 123
    commit: abcdef
```

## build-vi-package

See [build-vi-package](actions/build-vi-package.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/build-vi-package@v1
  with:
    minimum_supported_lv_version: '2023'
    supported_bitness: '64'
    labview_minor_revision: '3'
    relative_path: '.'
    vipb_path: 'Tooling/deployment/NI Icon editor.vipb'
    major: 1
    minor: 0
    patch: 0
    build: 2
    commit: abcdef
    display_information_json: '{"Package Version":{"major":1,"minor":0,"patch":0,"build":2}}'
```

## close-labview

See [close-labview](actions/close-labview.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/close-labview@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
```

## generate-release-notes

See [generate-release-notes](actions/generate-release-notes.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/generate-release-notes@v1
```

## missing-in-project

See [missing-in-project](actions/missing-in-project.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/missing-in-project@v1
  with:
    lv_version: '2020'
    arch: '64'
    project_file: 'MyProject.lvproj'
```

## modify-vipb-display-info

See [modify-vipb-display-info](actions/modify-vipb-display-info.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/modify-vipb-display-info@v1
  with:
    supported_bitness: '64'
    relative_path: '.'
    vipb_path: 'Tooling/deployment/NI Icon editor.vipb'
    minimum_supported_lv_version: '2023'
    labview_minor_revision: '3'
    major: 1
    minor: 0
    patch: 0
    build: 2
    commit: abcdef
    display_information_json: '{"Package Version":{"major":1,"minor":0,"patch":0,"build":2}}'
```

## prepare-labview-source

See [prepare-labview-source](actions/prepare-labview-source.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/prepare-labview-source@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    relative_path: '.'
    labview_project: 'lv_icon_editor'
    build_spec: 'Editor Packed Library'
```

## rename-file

See [rename-file](actions/rename-file.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/rename-file@v1
  with:
    current_filename: 'C:/path/lv_icon.lvlibp'
    new_filename: 'lv_icon_x64.lvlibp'
```

## restore-setup-lv-source

See [restore-setup-lv-source](actions/restore-setup-lv-source.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/restore-setup-lv-source@v1
  with:
    minimum_supported_lv_version: '2021'
    supported_bitness: '64'
    relative_path: '.'
    labview_project: 'lv_icon_editor'
    build_spec: 'Editor Packed Library'
```

## revert-development-mode

See [revert-development-mode](actions/revert-development-mode.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/revert-development-mode@v1
  with:
    relative_path: '.'
```

## run-pester-tests

See [run-pester-tests](actions/run-pester-tests.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/run-pester-tests@v1
  with:
    working_directory: '.'
```

## run-unit-tests

See [run-unit-tests](actions/run-unit-tests.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/run-unit-tests@v1
  with:
    minimum_supported_lv_version: '2020'
    supported_bitness: '64'
```

## set-development-mode

See [set-development-mode](actions/set-development-mode.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/set-development-mode@v1
  with:
    relative_path: '.'
```

## setup-mkdocs

See [setup-mkdocs](actions/setup-mkdocs.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions/setup-mkdocs@v1
```
