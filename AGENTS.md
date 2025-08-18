# AGENTS.md

## Environment Setup
- Run `apt-get update && apt-get install -y apt-utils` to ensure required APT utilities are available.
- Ensure Node.js 24 or newer is installed (e.g. via the NodeSource setup script).
- Install `actionlint` and ensure it is on your `PATH`:
  - `go install github.com/rhysd/actionlint/cmd/actionlint@latest`
- Ensure PowerShell 7.5.1 is installed and accessible.
  - Linux runners rely on preinstalled `pwsh`.
  - On Windows Server 2022 (build 10.0.20348), download the MSI and verify its SHA256 checksum before installing:

    ```powershell
    $url = 'https://github.com/PowerShell/PowerShell/releases/download/v7.5.1/PowerShell-7.5.1-win-x64.msi'
    Invoke-WebRequest -Uri $url -OutFile pwsh.msi
    $expected = (Invoke-WebRequest -Uri "$url.sha256").Content.Split()[0]
    if ((Get-FileHash pwsh.msi -Algorithm SHA256).Hash -ne $expected) { throw 'Checksum mismatch' }
    Start-Process msiexec.exe -Wait -ArgumentList '/i', 'pwsh.msi', '/qn', '/norestart'
    Remove-Item pwsh.msi
    ```
- PowerShell 7.5.1 includes native YAML support; external modules such as `powershell-yaml` are no longer required.

## Testing
- Run `npm run check:node` to verify Node.js satisfies the required version.
- Run `npm install` to ensure Node dependencies are available.
- Run `npm test`.
- Run `npm run lint:md` to lint Markdown files.
- Run `npx --yes markdown-link-check -q -c .markdown-link-check.json README.md $(find docs scripts -name '*.md')` to verify links.
- Run `actionlint` to validate GitHub Actions workflows.
- Run `pwsh -NoLogo -Command "$cfg = New-PesterConfiguration; $cfg.Run.Path = './tests/pester'; $cfg.TestResult.Enabled = $false; Invoke-Pester -Configuration $cfg"` and ensure all tests pass (XML output is intentionally disabled).
