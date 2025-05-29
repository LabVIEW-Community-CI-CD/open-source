# THREAD-v2025.5-STEERCO-AUTHORITY.md

**Status:** Declared  
**Version:** v2025.5  
**Owner:** Program Manager  
**Effective:** Upon merge to `main`  
**Repository:** [ni/open-source](https://github.com/ni/open-source)

---

## 📘 Purpose

This THREAD formalizes the interpretive rules and authority boundaries of the Steering Committee (STEERCO) within the NI LabVIEW Open Source Program. It governs interpretation of `STEERCO-GUIDELINES.md`, which defines STEERCO responsibilities, roles, and escalation pathways.

This THREAD ensures:
- GPTs and contributors do not misinterpret STEERCO power
- Authority disputes are traceable to policy
- Governance actions involving THREADs or CONTRACTs are properly scoped

---

## 📄 Scope of Governance

| File | Semantic Role | Interpretation Bound |
|------|----------------|----------------------|
| `STEERCO-GUIDELINES.md` | Strategic Policy | THREAD-v2025.5-STEERCO-AUTHORITY.md |

---

## 👥 Role Enforcement

- **STEERCO**:
  - Can escalate or override other THREADs only as scoped in `STEERCO-GUIDELINES.md`
  - Must operate within the roles and authorities declared in this THREAD
  - Cannot unilaterally declare new roles or alter GPT behavior unless scoped in THREAD

- **Program Manager**:
  - May interpret procedural alignment but not STEERCO voting or escalation logic

- **Contributors**:
  - May request STEERCO review or escalation per the guidelines, but cannot enforce policy

---

## 🤖 GPT Runtime Constraints

- GPTs may not assume STEERCO can create THREADs, enforce changes, or resolve disputes unless explicitly scoped
- GPTs must treat `STEERCO-GUIDELINES.md` as advisory unless this THREAD is active
- All GPT citation of STEERCO powers must reference `THREAD-v2025.5-STEERCO-AUTHORITY.md`

---

## 📎 File Expectations

The file `STEERCO-GUIDELINES.md` must:
- Define explicit escalation pathways
- Document scope of STEERCO authority by area (e.g., conflict resolution, release authority)
- Specify quorum or voting rules (if applicable)

---

## 🔧 Governance Extension

- Changes to STEERCO authority must be approved through this THREAD’s update mechanism
- Runtime changes to GPT interpretation models must cite this THREAD and its declared version
