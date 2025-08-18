# Quickstart

1. **Install Requirements:** Ensure you have **NI LabVIEW** (with command-line interface support, often via *g-cli*) installed on the target runner. Most actions require LabVIEW and the NI g-cli tool to be available (Ubuntu runners are recommended). Also verify PowerShell 7+ (`pwsh`) is available for cross-platform script execution. Install **Node.js 24+** and run `npm install` to pull in the TypeScript dependencies used by helper scripts.
2. **Invoke via Composite Action (GitHub):** Use the adapter-specific action in your workflow. For example, to **build a LabVIEW Packed Library**:

```yaml
jobs:
  build_lvlibp:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Packed Library (32-bit)
        uses: LabVIEW-Community-CI-CD/open-source-actions/build-lvlibp@v1
        with:
          minimum_supported_lv_version: '2019'
          supported_bitness: '32'
          working_directory: .
          relative_path: .
          labview_project: MyProject.lvproj
          build_spec: My Build
          major: 1
          minor: 0
          patch: 0
          build: 123
          commit: abcdef
```

In this step, the wrapper action invokes the dispatcher to run the **build-lvlibp** task. The typed inputs provide the required parameters to build a 32-bit LV library. The dispatcher locates the appropriate script and executes it, failing the step if a problem occurs.
3. **Invoke via PowerShell (CLI):** You can also call the dispatcher script directly. For example, the above build can be run in a PowerShell session or script:

```powershell
$json = @'
{
  "MinimumSupportedLVVersion": "2019",
  "SupportedBitness": "32",
  "WorkingDirectory": ".",
  "RelativePath": ".",
  "LabVIEW_Project": "MyProject.lvproj",
  "Build_Spec": "My Build",
  "Major": 1,
  "Minor": 0,
  "Patch": 0,
  "Build": 123,
  "Commit": "abcdef"
}
'@
pwsh -File actions/Invoke-OSAction.ps1 -ActionName build-lvlibp -ArgsJson $json
```

Arguments can also be loaded from a JSON file:

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName build-lvlibp -ArgsFile ./config/build.json
```

This will import the **OpenSourceActions** module and run the **Build** adapter. On completion, the script returns with an exit code (0 for success or a non-zero error code). You can include optional flags like `-WorkingDirectory` to change directory before execution, or `-DryRun` to simulate the action (see below). For details on these and other dispatcher flags, see [Common Parameters](common-parameters.md).
4. **Confirm Results:** After running, check the console output and exit code. The unified dispatcher prints informative logs (at INFO level by default) and any errors encountered. For GitHub Actions, a non-zero exit code will mark the step as failed, surfacing any error messages thrown by the adapter or underlying script.

### Build Icon Editor

Chain the [apply-vipc](actions/apply-vipc.md), [set-development-mode](actions/set-development-mode.md), [build](actions/build.md), and [revert-development-mode](actions/revert-development-mode.md) actions to build the LabVIEW Icon Editor:

```yaml
jobs:
  build_icon_editor:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/checkout@v4
        with:
          repository: LabVIEW-Community-CI-CD/labview-icon-editor
          path: labview-icon-editor
      - uses: LabVIEW-Community-CI-CD/open-source-actions/apply-vipc@v1
        with:
          minimum_supported_lv_version: '2021'
          vip_lv_version: '2021'
          supported_bitness: '64'
          working_directory: labview-icon-editor
          relative_path: '.'
          vipc_path: labview-icon-editor/.github/actions/apply-vipc/runner_dependencies.vipc
      - uses: LabVIEW-Community-CI-CD/open-source-actions/set-development-mode@v1
        with:
          minimum_supported_lv_version: '2021'
          supported_bitness: '64'
          working_directory: labview-icon-editor
          relative_path: '.'
      - uses: LabVIEW-Community-CI-CD/open-source-actions/build@v1
        with:
          working_directory: labview-icon-editor
          relative_path: '.'
          major: 1
          minor: 0
          patch: 0
          build: 0
          commit: abcdef
          labview_minor_revision: '3'
          company_name: 'Acme Corp'
          author_name: 'Jane Doe'
      - uses: LabVIEW-Community-CI-CD/open-source-actions/revert-development-mode@v1
        with:
          working_directory: labview-icon-editor
          relative_path: '.'
```

## Need help?

See the [troubleshooting guide](troubleshooting.md) for help with setup issues, missing dependencies, and exit codes.
