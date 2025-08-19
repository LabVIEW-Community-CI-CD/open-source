# Environment Setup

This guide lists the tooling required to contribute to Open Source LabVIEW Actions and how to verify each component.

## PowerShell 7.5.1

PowerShell 7.5.1 or newer is required. Verify the version:

```bash
pwsh --version
```

## Node.js 24+

Install Node.js 24 or newer. Verify the installation:

```bash
node --version
```

## actionlint

[actionlint](https://github.com/rhysd/actionlint) validates GitHub Actions workflows.
Install it with Go and confirm it is on `PATH`:

```bash
go install github.com/rhysd/actionlint/cmd/actionlint@latest
actionlint -version
```

## g-cli

Some actions rely on NI's LabVIEW command-line interface (g-cli).
On Windows the executable typically resides at `C:\Program Files\G-CLI\bin\g-cli.exe`.
Verify availability with:

```powershell
& 'C:\Program Files\G-CLI\bin\g-cli.exe' --version
# or if on PATH
g-cli --version
```

## Optional: LABVIEW_ICON_EDITOR_PATH

Set `LABVIEW_ICON_EDITOR_PATH` if a nonstandard icon editor is required. Check the value with:

```powershell
echo $env:LABVIEW_ICON_EDITOR_PATH
```
