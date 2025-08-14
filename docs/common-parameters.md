# Common Parameters

Calls to `actions/Invoke-OSAction.ps1` share a core set of flags and environment variables.

## Command-line flags

### `-LogLevel`

Controls logging verbosity. Allowed values: `ERROR`, `WARN`, `INFO` (default), `DEBUG`.

Example:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{}' -LogLevel DEBUG
```

### `-DryRun`

Prints the adapter invocation without executing it.

Example:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{}' -DryRun
```

### `-WorkingDirectory`

Runs the adapter after changing to the specified directory using `-WorkingDirectory`.

Example:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{}' -WorkingDirectory src
```

### `-ListActions`

Lists available actions then exits.

Example:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ListActions
```

### `-Describe`

Shows the parameters for a specific action then exits.

Example:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -Describe run-unit-tests
```

## Environment variables

### `gcliPath`

Optional path to the NI g-cli executable. When provided in `args_json`, the dispatcher prepends it to `PATH`. Default: assumes `g-cli` is already on `PATH`.

Example:

```powershell
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{"gcliPath":"/opt/gcli/bin"}'
```

### `PSModulePath`

PowerShell uses this variable to locate modules. The dispatcher honors the value inherited from the environment. Override it before invoking the dispatcher to load custom modules.

Example:

```powershell
$env:PSModulePath = "$PWD/modules"
pwsh ./actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{}'
```
