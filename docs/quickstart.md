# Quickstart

1. **Install Requirements:** Ensure you have **NI LabVIEW** (with command-line interface support, often via *g-cli*) installed on the target runner. Most actions require LabVIEW and the NI g-cli tool to be available (Windows runners are recommended). Also verify PowerShell 7+ (`pwsh`) is available for cross-platform script execution.
2. **Invoke via Composite Action (GitHub):** Use the provided composite action in your workflow. For example, to **build a LabVIEW Packed Library** using this unified dispatcher:

```yaml
jobs:
  build_lvlibp:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build Packed Library (32-bit)
        uses: LabVIEW-Community-CI-CD/open-source-actions@v1
        with:
          action_name: build-lvlibp
          args_json: >
            {
              "MinimumSupportedLVVersion": "2019",
              "SupportedBitness": "32",
              "RelativePath": ".",
              "LabVIEW_Project": "MyProject.lvproj",
              "Build_Spec": "My Build",
              "Major": 1,
              "Minor": 0,
              "Patch": 0,
              "Build": 123,
              "Commit": "abcdef"
            }
```

In this step, the composite action invokes the dispatcher to run the **Build** task. The `args_json` contains all parameters the action needs (here, to build a 32-bit LV library). The dispatcher will locate the appropriate script and execute it, failing the step if a problem occurs (non-zero exit).
3. **Invoke via PowerShell (CLI):** You can also call the dispatcher script directly. For example, the above build can be run in a PowerShell session or script:

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName build-lvlibp -ArgsJson '{
  "MinimumSupportedLVVersion": "2019",
  "SupportedBitness": "32",
  "RelativePath": ".",
  "LabVIEW_Project": "MyProject.lvproj",
  "Build_Spec": "My Build",
  "Major": 1,
  "Minor": 0,
  "Patch": 0,
  "Build": 123,
  "Commit": "abcdef"
}'
```

This will import the **OpenSourceActions** module and run the **Build** adapter. On completion, the script returns with an exit code (0 for success or a non-zero error code). You can include optional flags like `-WorkingDirectory` to change directory before execution, or `-DryRun` to simulate the action (see below). For details on these and other dispatcher flags, see [Common Parameters](common-parameters.md).
4. **Confirm Results:** After running, check the console output and exit code. The unified dispatcher prints informative logs (at INFO level by default) and any errors encountered. For GitHub Actions, a non-zero exit code will mark the step as failed, surfacing any error messages thrown by the adapter or underlying script.

## Need help?

See the [troubleshooting guide](troubleshooting.md) for help with setup issues, missing dependencies, and exit codes.
