# run-unit-tests

## Purpose
Run LabVIEW unit tests via the LabVIEW Unit Test Framework CLI and report pass/fail/error using standard exit codes.

## Parameters

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
  uses: LabVIEW-Community-CI-CD/open-source-actions/abstract-action@v1
  with:
    action_name: run-unit-tests
    args_json: >-
      {
        "MinimumSupportedLVVersion": "2020",
        "SupportedBitness": "64"
      }
```

## Return Codes
Parses `UnitTestReport.xml` to summarize results.

- `0` – all tests passed
- `2` – tests failed
- `3` – g-cli or test run error

Use `-DryRun` to log the sequence without executing.
