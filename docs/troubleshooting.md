# Troubleshooting

## Setup issues

- Ensure NI LabVIEW and g-cli are installed and accessible.
- Verify PowerShell 7+ (`pwsh`) is available on the PATH.
- Confirm the working directory and file paths are correct.

## Missing dependencies

- Check that required packages and toolkits are installed.
- Install any missing modules or scripts referenced by the action.
- Review action parameters for typos that could hide dependencies.

## Interpreting exit codes

- `0` indicates success; any non-zero code signals a failure.
- Consult each action's documentation for specific return codes.
- Use verbose logs to pinpoint the cause of unexpected codes.

## Missing g-cli or LabVIEW

**Symptom:** Actions fail immediately because g-cli or LabVIEW is absent or misconfigured.

**Example error output**

```text
❌  g-cli executable not found in PATH.
Invoke-OSAction.ps1 : g-cli: command not found
```

**Resolution**

1. Install NI LabVIEW and g-cli.
2. If g-cli isn't on `PATH`, provide its location via [`gcliPath`](common-parameters.md#gclipath).
3. Verify the path uses proper separators and escaping.

## 32- vs 64-bit mismatches

**Symptom:** g-cli cannot find the requested LabVIEW architecture.

**Example error output**

```text
Unsupported VIP_LVVersion or SupportedBitness for VIP_LVVersion_A.
g-cli: could not locate LabVIEW 2021 (64-bit)
```

**Resolution**

1. Ensure the installed LabVIEW bitness matches the `SupportedBitness` argument.
2. Confirm action configuration (e.g., [`run-unit-tests`](actions/run-unit-tests.md)) specifies the correct `SupportedBitness`.
3. Use a g-cli build that matches the target architecture.

## Permission or working-directory errors

**Symptom:** Files or directories cannot be accessed.

**Example error output**

```text
Invoke-OSAction.ps1 : Cannot find path 'C:\\repo\\project' because it does not exist.
Access to the path '/opt/labview/Tooling' is denied.
```

**Resolution**

1. Verify the working directory is correct or set [`-WorkingDirectory`](common-parameters.md#workingdirectory).
2. Ensure the runner has permission to read/write the necessary paths.
