# Runner Types: Integration vs Default

Modern CI pipelines in this repository classify runners into two categories to control cost and coverage. Understanding the difference allows you to target expensive resources only when necessary and keep feedback cycles fast.

## Default ("standard") runners

* **Environment** – GitHub-hosted virtual machines such as `ubuntu-latest` or `windows-latest`.
* **Use cases** – Linting, unit tests and any step that can run on a clean ephemeral image.
* **Configuration** – In a requirement mapping file (for example, `requirements-core.json`) omit `runner_type` or set it to `standard`. Workflows simply use `runs-on: ubuntu-latest` or similar.
* **Characteristics** – High concurrency, minimal boot time and no persistent state. Ideal for rapid validation.

## Integration runners

* **Environment** – Long-lived machines with preinstalled tooling such as LabVIEW, g-cli and hardware drivers. They may be self-hosted or specialized GitHub images.
* **Use cases** – End‑to‑end scenarios that interact with external systems, require licensed software or need deterministic state.
* **Configuration** – Tag the runner with `runner_type: "integration"` in the appropriate mapping file and reference the runner by label in workflows. Integration entries often set `skip_dry_run: true` to force real execution.
* **Characteristics** – Limited availability and higher cost; jobs are serialized to protect shared resources. Treat these runners as scarce infrastructure.

## Declaring runner types

Requirement mapping files define which runner each test or requirement targets:

```json
{
  "runners": {
    "ubuntu-latest": {
      "runner_label": "ubuntu-latest",
      "runner_type": "integration"
    },
    "windows-latest": {
      "runner_label": "windows-latest"
      /* implicit runner_type: "standard" */
    }
  },
  "requirements": [
    {
      "id": "REQ-009",
      "runner": "ubuntu-latest",
      "tests": ["Build.Workflow"]
    }
  ]
}
```

The summarizer partitions results by `runner_type`, producing artifacts such as `summary-integration.md` alongside `summary-standard.md`. This separation keeps integration evidence distinct from fast feedback produced on default runners.

## Recommendations for CI/CD engineers

1. **Minimize integration usage.** Start with standard runners and move tests to integration environments only when they require external dependencies or state.
2. **Isolate heavy workflows.** Place integration jobs in separate stages or repositories to avoid blocking quick validation paths.
3. **Protect self-hosted runners.** Apply concurrency limits and explicit `needs` chains so multiple integration jobs do not compete for the same hardware.
4. **Audit runner labels.** Keep requirement mapping files synchronized with the actual fleet of self-hosted machines. Stale labels lead to idle jobs.
5. **Document expectations.** When adding new requirements or workflows, update `docs/requirements.md` so the `Runner` and `Runner Type` columns reflect the intended infrastructure.

By explicitly classifying jobs, teams can scale the project efficiently—routine tasks remain fast on default runners while integration tests validate real‑world behavior without overloading scarce resources.

## Updating runner metadata

Administrators can modify runner mappings without opening a pull request by using the `update-runner-runtime` workflow. Trigger the workflow from the Actions tab and supply the following inputs:

* `runner_key` – key of the runner in the requirements file.
* `runner_label` – label applied to the runner.
* `runner_type` – value for `runner_type` such as `standard` or `integration`.
* `skip_dry_run` – set to `true` to force real execution.

The workflow updates the corresponding `requirements*.json` file, commits the change with `GITHUB_TOKEN`, and optionally runs registry derivation, traceability checks, and `actionlint` to validate the update.
