# Apply VIPC Dependencies 📦

Ensure a runner has all required LabVIEW packages installed before building or testing. This composite action calls **`ApplyVIPC.ps1`** to apply a `.vipc` container through **g-cli**. The action automatically detects the `runner_dependencies.vipc` file located in this directory.

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Inputs](#inputs)
3. [Quick-start](#quick-start)
4. [How it works](#how-it-works)
5. [Troubleshooting](#troubleshooting)
6. [License](#license)

---

## Prerequisites

| Requirement | Notes |
|-------------|-------|
| **Windows runner** | LabVIEW and g-cli are Windows only. |
| **LabVIEW** `>= 2021` | Must match both `minimum_supported_lv_version` and `vip_lv_version`. |
| **g-cli** in `PATH` | Used to apply the `.vipc` container. Install from NI Package Manager or include the executable in the runner image. |
| **PowerShell 7** | Composite steps use PowerShell Core (`pwsh`). |

---

## Inputs

| Name | Required | Example | Description |
|------|----------|---------|-------------|
| `minimum_supported_lv_version` | **Yes** | `2021` | LabVIEW *major* version that the repo supports. |
| `vip_lv_version` | **Yes** | `2021` | LabVIEW version used to apply the `.vipc` file. Usually the same as `minimum_supported_lv_version`. |
| `supported_bitness` | **Yes** | `32` or `64` | LabVIEW bitness to target. |
| `relative_path` | **Yes** | `${{ github.workspace }}` | Root path of the repository on disk. |

---

## Quick-start

```yaml
# .github/workflows/ci-composite.yml (excerpt)
steps:
  - uses: actions/checkout@v4
  - name: Install LabVIEW dependencies
    uses: ./.github/actions/apply-vipc
    with:
      minimum_supported_lv_version: 2021
      vip_lv_version: 2021
      supported_bitness: 64
      relative_path: ${{ github.workspace }}
```

The CI pipeline applies these dependencies across multiple LabVIEW versions—2021 (32-bit and 64-bit) and 2023 (64-bit)—as shown in
[`.github/workflows/ci.yml`](../../.github/workflows/ci.yml).

---

## How it works

1. **Checkout** – pulls the repository to ensure scripts and the `.vipc` file are present.
2. **PowerShell wrapper** – executes `ApplyVIPC.ps1` with the provided inputs.
3. **g-cli invocation** – `ApplyVIPC.ps1` launches **g-cli** to apply the `.vipc` container to the specified LabVIEW installation.
4. **Failure propagation** – any error in path resolution, g-cli, or the script causes the step (and job) to fail.

---

## Troubleshooting

| Symptom | Hint |
|---------|------|
| *g-cli executable not found* | Ensure g-cli is installed and on `PATH`. |
| *`.vipc` file not found* | Ensure `runner_dependencies.vipc` exists in this action directory. |
| *LabVIEW version mismatch* | Make sure the installed LabVIEW version matches both version inputs. |

---

See also: [docs/actions/apply-vipc.md](../../docs/actions/apply-vipc.md)

## License

This directory inherits the root repository’s license (MIT, unless otherwise noted).
