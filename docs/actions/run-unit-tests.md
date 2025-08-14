# run-unit-tests

## Purpose

Run LabVIEW unit tests via the LabVIEW Unit Test Framework CLI and report pass/fail/error using standard exit codes.

## Parameters

Common parameters are described in [Common parameters](../common-parameters.md).

### Required

- **MinimumSupportedLVVersion** (`string`): LabVIEW version for the test run.
- **SupportedBitness** (`string`): "32" or "64" bitness of LabVIEW.

### Optional

None.

## CLI example

```powershell
pwsh -File actions/Invoke-OSAction.ps1 -ActionName run-unit-tests -ArgsJson '{
  "MinimumSupportedLVVersion": "2020",
  "SupportedBitness": "64"
}'
```

## GitHub Action example

```yaml
- name: Run LabVIEW Unit Tests
  uses: LabVIEW-Community-CI-CD/open-source-actions@v1
  with:
    action_name: run-unit-tests
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2020",
        "SupportedBitness": "64"
      }
```

## Return Codes

- `0` – all tests passed
- `2` – tests failed
- `3` – g-cli or test run error

For troubleshooting tips, see the [troubleshooting guide](../troubleshooting.md).

Source: [scripts/run-unit-tests/](https://github.com/LabVIEW-Community-CI-CD/open-source-actions/tree/actions/scripts/run-unit-tests/)
