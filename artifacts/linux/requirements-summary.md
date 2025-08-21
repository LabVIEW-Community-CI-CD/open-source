### Requirement Summary
| Requirement ID | Description | Owner | Total Tests | Passed | Failed | Skipped | Pass Rate (%) |
| --- | --- | --- | --- | --- | --- | --- | --- |
| REQ-023 | Parser ingests JUnit XML artifacts starting at the testsuites root and iterating through nested suites and testcases. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-024 | Top-level testsuites attributes name, tests, errors, failures, disabled, and time are captured for summary reporting. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-025 | Each testsuite records attributes including name, tests, errors, failures, hostname, id, skipped, disabled, package, and time. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-026 | Suite properties are extracted as name/value pairs for environment details. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-027 | Testcase attributes name, status, classname, assertions, time, and any skip message are preserved. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-028 | Requirement identifiers embedded in testcase names are detected and associated with the test. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-029 | Test results are aggregated by requirement and by suite to count passed, failed, and skipped cases. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-030 | Traceability matrix links requirement IDs to testcases with status, execution time, host properties, and skipped reasons. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-031 | Parsing logic validates presence of required fields and reports missing or malformed data. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-032 | Parser tolerates and retains unknown attributes for future extensibility. |  | 1 | 1 | 0 | 0 | 100.00 |
| REQ-033 | Tests ending with SelfHosted.Workflow.Tests.ps1 execute only in dry run mode unless the workflow targets a self-hosted Windows runner labeled self-hosted-windows-lv. |  | 1 | 1 | 0 | 0 | 100.00 |
| Unmapped |  |  | 48 | 48 | 0 | 0 | 100.00 |

### Requirement Testcases
| Requirement ID | Test ID | Status |
| --- | --- | --- |
| REQ-023 | parses-nested-junit-structures | Passed |
| REQ-024 | captures-root-testsuites-attributes | Passed |
| REQ-025 | captures-testsuite-attributes | Passed |
| REQ-026 | captures-suite-properties | Passed |
| REQ-027 | captures-testcase-attributes-and-skipped-message | Passed |
| REQ-028 | extracts-requirement-identifiers | Passed |
| REQ-029 | aggregates-status-by-requirement-and-suite | Passed |
| REQ-030 | builds-traceability-matrix-with-skipped-reasons | Passed |
| REQ-031 | validates-missing-fields | Passed |
| REQ-032 | preserves-unknown-attributes | Passed |
| REQ-033 | throws-error-for-malformed-xml | Passed |
| Unmapped | associates-classname-with-requirement | Passed |
| Unmapped | buildissuebranchname-formats-branch-name | Passed |
| Unmapped | buildissuebranchname-rejects-non-numeric-input | Passed |
| Unmapped | buildprofile1.iconeditor.addtokentolabview.dispatcher.dry-runs-add-token-to-labview-with-expected-arguments- | Passed |
| Unmapped | buildprofile1.iconeditor.applyvipc.dispatcher.dry-runs-apply-vipc-with-expected-arguments- | Passed |
| Unmapped | buildprofile1.iconeditor.buildvipackage.dispatcher.dry-runs-build-vi-package-with-expected-arguments- | Passed |
| Unmapped | buildprofile1.iconeditor.closelabview.dispatcher.dry-runs-close-labview-with-expected-arguments- | Passed |
| Unmapped | buildsummary-splits-totals-by-os | Passed |
| Unmapped | collecttestcases-captures-requirement-property | Passed |
| Unmapped | collecttestcases-uses-evidence-property-and-falls-back-to-directory-scan | Passed |
| Unmapped | collecttestcases-uses-machine-name-property-for-owner | Passed |
| Unmapped | computestatuscounts-tallies-test-statuses | Passed |
| Unmapped | detects-downloaded-artifacts-path | Passed |
| Unmapped | dispatchers-and-parameters-include-descriptions | Passed |
| Unmapped | errors-when-strict-unmapped-mode-enabled | Passed |
| Unmapped | escapemarkdown-escapes-special-characters | Passed |
| Unmapped | escapemarkdown-leaves-plain-text-untouched | Passed |
| Unmapped | fails-when-commit-lacks-requirement-reference | Passed |
| Unmapped | fails-when-requirement-lacks-test-coverage | Passed |
| Unmapped | fails-when-tests-are-unmapped | Passed |
| Unmapped | fails-when-tests-reference-unknown-requirements | Passed |
| Unmapped | formaterror-handles-plain-objects | Passed |
| Unmapped | formaterror-handles-primitives | Passed |
| Unmapped | formaterror-handles-real-error-objects | Passed |
| Unmapped | formaterror-handles-unstringifiable-values | Passed |
| Unmapped | generate-ci-summary-features | Passed |
| Unmapped | groups-owners-and-includes-requirements-and-evidence | Passed |
| Unmapped | grouptomarkdown-omits-numeric-identifiers | Passed |
| Unmapped | grouptomarkdown-supports-optional-limit-for-truncation | Passed |
| Unmapped | handles-root-level-testcases | Passed |
| Unmapped | handles-zipped-junit-artifacts | Passed |
| Unmapped | ignores-stale-junit-files-outside-artifacts-path | Passed |
| Unmapped | loadrequirements-logs-warning-on-invalid-json | Passed |
| Unmapped | loadrequirements-merges-multiple-files | Passed |
| Unmapped | loadrequirements-warns-and-skips-invalid-entries | Passed |
| Unmapped | logs-a-warning-when-no-junit-files-are-found | Passed |
| Unmapped | partitions-requirement-groups-by-runner\_type | Passed |
| Unmapped | passes-with-coverage-and-requirement-reference | Passed |
| Unmapped | requirementssummarytomarkdown-escapes-pipes-in-description | Passed |
| Unmapped | skips-invalid-junit-files-and-still-generates-summary | Passed |
| Unmapped | summarytomarkdown-handles-no-tests | Passed |
| Unmapped | summarytomarkdown-sorts-os-alphabetically-and-escapes-special-characters | Passed |
| Unmapped | throws-when-no-junit-files-found-and-strict-mode-enabled | Passed |
| Unmapped | uses-latest-artifact-directory-when-multiple-are-present | Passed |
| Unmapped | warns-when-all-tests-are-unmapped | Passed |
| Unmapped | writeerrorsummary-appends-error-details-to-summary-file | Passed |
| Unmapped | writeerrorsummary-skips-summary-file-for-non-error-throws | Passed |
| Unmapped | writes-outputs-to-os-specific-directory | Passed |