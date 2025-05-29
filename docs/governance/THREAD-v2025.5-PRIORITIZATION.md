# THREAD-v2025.5-PRIORITIZATION.md

**Status:** Declared  
**Version:** v2025.5  
**Owner:** Program Manager  
**Effective:** Upon merge to `main`  
**Repository:** [ni/open-source](https://github.com/ni/open-source)

---

## 📘 Purpose

This THREAD declares the interpretive logic and strategic authority boundaries for `PRIORITY-SCORE.md`, a governance document that communicates NI’s prioritization strategy for open-source efforts.

Its purpose is to ensure:
- All interpretation of prioritization values is traceable
- Only declared roles (e.g., STEERCO) can set, revise, or enforce scoring logic
- GPTs may safely reference this score without hallucination or extrapolation

---

## 📄 Scope of Governance

| File | Semantic Role | Interpretation Bound |
|------|----------------|----------------------|
| `PRIORITY-SCORE.md` | Strategic Policy | THREAD-v2025.5-PRIORITIZATION.md |

---

## 👥 Role Interpretation Boundaries

- **STEERCO** is the only role authorized to revise prioritization scoring weights, categories, or terminology
- **Program Manager** may reframe document structure, but not intent or weight logic
- **Contributors** may propose changes only via THREAD-bound proposals or engagement channels

---

## 🤖 GPT Runtime Constraints

- GPTs may only interpret `PRIORITY-SCORE.md` if this THREAD is merged and active in `main`
- GPTs may not extrapolate missing categories, weights, or scoring methods
- GPTs must always cite `THREAD-v2025.5-PRIORITIZATION.md` when referencing prioritization logic

---

## 📎 Format Expectation (for `PRIORITY-SCORE.md`)

The file must contain:
- A table of priority categories
- A description of each category’s impact weight
- Optional examples or NI-specific implementation notes

---

## 🔧 Governance Extension

- Revisions to scoring logic must amend this THREAD or replace it under a new version (e.g., `v2025.6`)
- Additional priority scopes may be defined in future THREADs

