# Pester Testing

## Setup

Most tests run without cloning the [`labview-icon-editor`](https://github.com/LabVIEW-Community-CI-CD/labview-icon-editor) repository. The helper defaults to the repository root as the project directory.

Tests that need the example project can either clone it under `open-source-actions/labview-icon-editor`:

```bash
git clone https://github.com/LabVIEW-Community-CI-CD/labview-icon-editor.git labview-icon-editor
```

or set `LABVIEW_ICON_EDITOR_PATH` to the location of an existing clone:

```bash
export LABVIEW_ICON_EDITOR_PATH=/path/to/labview-icon-editor
```

To enforce that the project exists, set `LABVIEW_ICON_EDITOR_REQUIRED=1` or call `Get-LabVIEWIconEditorArgsJson -RequireProject` in your test.

Required tooling:

- PowerShell 7.5.1
- Node.js 24 or newer
- [`actionlint`](https://github.com/rhysd/actionlint)

Sample command sequence to run the suite:

```powershell
npm install
actionlint
$cfg = New-PesterConfiguration
$cfg.Run.Path = './tests/pester'
$cfg.TestResult.Enabled = $false
Invoke-Pester -Configuration $cfg
```

## Canonical argument helper

Pester tests share a small helper module, `tests/pester/Helper/ArgsJson.psm1`, which exposes `Get-LabVIEWIconEditorArgsJson`. The function returns a canonical set of dispatcher arguments and the project root so every test starts from the same baseline. Using the helper avoids repeating boilerplate and keeps tests resilient to environment differences.

## labview-icon-editor reference project

When available, the helper points at the **labview-icon-editor** project. This open-source repository is tiny, exercises common LabVIEW project layouts and does not require NI components to execute in dry-run mode. Using it as the reference project gives all tests a consistent, real-world example without adding heavy dependencies.

## Adding new tests

1. Create a `*.Tests.ps1` file under `tests/pester` or one of its subfolders.
2. Import the helper module:
   ```powershell
   Import-Module (Join-Path $PSScriptRoot 'Helper' 'ArgsJson.psm1')
   ```
3. Use `Get-LabVIEWIconEditorArgsJson` to obtain the canonical JSON and working directory for dispatcher calls.
4. Include both positive and negative path tests where practical.
5. Run the suite before submitting a pull request with:

   ```powershell
   $cfg = New-PesterConfiguration
   $cfg.Run.Path = './tests/pester'
   $cfg.TestResult.Enabled = $false
   Invoke-Pester -Configuration $cfg
   ```

   XML test result output is intentionally disabled.

### Positive path example

```powershell
It 'describes a known action' {
  $params = Get-LabVIEWIconEditorArgsJson
  $json = $params.ArgsJson
  $wd = $params.WorkingDirectory
  $out = pwsh -NoProfile -File $global:dispatcher -Describe build-lvlibp -ArgsJson $json -WorkingDirectory $wd | Out-String
  $out | Should -Match 'Major'
}
```

### Negative path example

```powershell
It 'fails on unknown action' {
  $params = Get-LabVIEWIconEditorArgsJson
  $json = $params.ArgsJson
  $wd = $params.WorkingDirectory
  pwsh -NoProfile -File $global:dispatcher -ActionName no-such-action -ArgsJson $json -WorkingDirectory $wd *>$null
  $LASTEXITCODE | Should -Be 1
}
```
