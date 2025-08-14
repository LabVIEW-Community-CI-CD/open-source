# Action Call Reference

Use the composite action to invoke any adapter by specifying its `action_name` and JSON arguments. Each section below shows a sample GitHub Actions step for calling one of the available actions. Refer to the linked action documentation for parameter details and return codes. See [common parameters](common-parameters.md) for options shared across actions.

## add-token-to-labview

See [add-token-to-labview](actions/add-token-to-labview.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: add-token-to-labview
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2021",
        "SupportedBitness": "64",
        "RelativePath": "."
      }
```

## apply-vipc

See [apply-vipc](actions/apply-vipc.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: apply-vipc
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2019",
        "VIP_LVVersion": "2019",
        "SupportedBitness": "64",
        "RelativePath": ".",
        "VIPCPath": "MyProject.vipc"
      }
```

## build

See [build](actions/build.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: build
    args_json: >-
      {
        "RelativePath": ".",
        "Major": 1,
        "Minor": 0,
        "Patch": 0,
        "Build": 1,
        "Commit": "abcdef",
        "LabVIEWMinorRevision": "3",
        "CompanyName": "Acme Corp",
        "AuthorName": "Jane Doe"
      }
```

## build-lvlibp

See [build-lvlibp](actions/build-lvlibp.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: build-lvlibp
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2020",
        "SupportedBitness": "64",
        "RelativePath": ".",
        "LabVIEW_Project": "Source/MyProject.lvproj",
        "Build_Spec": "PackedLib Build",
        "Major": 1,
        "Minor": 0,
        "Patch": 0,
        "Build": 123,
        "Commit": "abcdef"
      }
```

## build-vi-package

See [build-vi-package](actions/build-vi-package.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: build-vi-package
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2023",
        "SupportedBitness": "64",
        "LabVIEWMinorRevision": "3",
        "RelativePath": ".",
        "VIPBPath": "Tooling/deployment/NI Icon editor.vipb",
        "Major": 1,
        "Minor": 0,
        "Patch": 0,
        "Build": 2,
        "Commit": "abcdef",
        "DisplayInformationJSON": "{\"Package Version\":{\"major\":1,\"minor\":0,\"patch\":0,\"build\":2}}"
      }
```

## close-labview

See [close-labview](actions/close-labview.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: close-labview
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2021",
        "SupportedBitness": "64"
      }
```

## generate-release-notes

See [generate-release-notes](actions/generate-release-notes.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: generate-release-notes
    args_json: >-
      {
        "OutputPath": "Tooling/deployment/release_notes.md"
      }
```

## missing-in-project

See [missing-in-project](actions/missing-in-project.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: missing-in-project
    args_json: >-
      {
        "LVVersion": "2020",
        "Arch": "64",
        "ProjectFile": "MyProject.lvproj"
      }
```

## modify-vipb-display-info

See [modify-vipb-display-info](actions/modify-vipb-display-info.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: modify-vipb-display-info
    args_json: >-
      {
        "SupportedBitness": "64",
        "RelativePath": ".",
        "VIPBPath": "Tooling/deployment/NI Icon editor.vipb",
        "MinimumSupportedLVVersion": "2023",
        "LabVIEWMinorRevision": "3",
        "Major": 1,
        "Minor": 0,
        "Patch": 0,
        "Build": 2,
        "Commit": "abcdef",
        "DisplayInformationJSON": "{\"Package Version\":{\"major\":1,\"minor\":0,\"patch\":0,\"build\":2}}"
      }
```

## prepare-labview-source

See [prepare-labview-source](actions/prepare-labview-source.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: prepare-labview-source
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2021",
        "SupportedBitness": "64",
        "RelativePath": ".",
        "LabVIEW_Project": "lv_icon_editor",
        "Build_Spec": "Editor Packed Library"
      }
```

## rename-file

See [rename-file](actions/rename-file.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: rename-file
    args_json: >-
      {
        "CurrentFilename": "C:/path/lv_icon.lvlibp",
        "NewFilename": "lv_icon_x64.lvlibp"
      }
```

## restore-setup-lv-source

See [restore-setup-lv-source](actions/restore-setup-lv-source.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: restore-setup-lv-source
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2021",
        "SupportedBitness": "64",
        "RelativePath": ".",
        "LabVIEW_Project": "lv_icon_editor",
        "Build_Spec": "Editor Packed Library"
      }
```

## revert-development-mode

See [revert-development-mode](actions/revert-development-mode.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: revert-development-mode
    args_json: >-
      {
        "RelativePath": "."
      }
```

## run-unit-tests

See [run-unit-tests](actions/run-unit-tests.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: run-unit-tests
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2020",
        "SupportedBitness": "64"
      }
```

## set-development-mode

See [set-development-mode](actions/set-development-mode.md) for all parameters.

```yaml
- uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: set-development-mode
    args_json: >-
      {
        "RelativePath": "."
      }
```
