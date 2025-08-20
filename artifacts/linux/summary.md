### Test Summary
| OS | Passed | Failed | Skipped | Duration (s) | Pass Rate (%) |
| --- | --- | --- | --- | --- | --- |
| overall | 53 | 0 | 0 | 13.80 | 100.00 |
| linux | 53 | 0 | 0 | 13.80 | 100.00 |

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
| Unmapped |  |  | 42 | 42 | 0 | 0 | 100.00 |

_For detailed per-test information, see [traceability.md](traceability.md)._