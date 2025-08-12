# Architecture

The Open Source Actions project exposes multiple LabVIEW CI/CD steps through a single dispatcher and a set of adapter scripts.

## Dispatcher

`Invoke-OSAction.ps1` routes incoming requests to the appropriate adapter script. The dispatcher discovers available actions, forwards command-line arguments, and preserves exit codes.

## Adapter scripts

Each action lives in a `scripts/<action-name>` folder. These PowerShell scripts implement the build or test work and are invoked by the dispatcher with the JSON arguments supplied by the GitHub Action.

## Composite action layout

Composite actions share a common template in `actions/abstract-action`. Each published action folder wraps the dispatcher, pointing to the relevant adapter script with parameters and metadata.

## Repository layout

- `actions/` – dispatcher and composite action template
- `docs/` – MkDocs documentation, including this page
- `scripts/` – adapter scripts invoked by the dispatcher
- `tests/` – Pester tests and other verification scripts
- `tools/` – utilities for building or testing actions
