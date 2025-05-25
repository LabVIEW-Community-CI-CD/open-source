# RECOGNITION-TAG-MAP.md

> 🏷️ Defines which GitHub labels, templates, and contributor actions are recognized by the NI Open-Source Governance Framework — and what recognition outcomes they trigger.

---

## Purpose

This file provides a transparent mapping between:
- Contributor activity in GitHub
- Labels, templates, and metadata used
- The recognition or scoring outcome generated

This enables automation, fairness, and contributor confidence in the badge and scoring process.

---

## Tag-to-Badge Mapping

| GitHub Label / Metadata      | Trigger Type     | Recognition Outcome        |
|------------------------------|------------------|-----------------------------|
| `test result`                | Issue label      | Eligible for Test Coordinator badge |
| Uses `Manual Test Report` template | PR or Issue body | Required for scoring + badge |
| `#manual-edit`               | Comment tag      | Flags governance override; may disable scoring |
| `enhancement`                | Issue label      | No badge, but may affect project scoring |
| PR linked to SteerCo-scored issue | PR metadata     | Eligible for SteerCo contribution credit |
| Nomination in Discussions    | Comment trigger  | May trigger badge nomination |
| Uses `PR Template` with all fields | PR metadata     | Required for certification score eligibility |

---

## Template-Based Eligibility

| Required Template          | Applies To         | Outcome                  |
|----------------------------|--------------------|---------------------------|
| `Manual Test Report`       | Test submissions   | Badge + scoring required |
| `PR Template`              | All pull requests  | Required for recognition tracking |
| (Planned) `Maintainer Endorsement Form` | Badge nominations | Maintainer badge approval (future) |

---

## Automation Notes

- These tags may be counted via GitHub Actions, issue filters, or PR metadata scans
- Contributors who bypass templates must be approved via `#manual-override` or discussed via governance appeal

---

Maintained by: Program Manager & Architect  
Last updated: 2025-05-25
