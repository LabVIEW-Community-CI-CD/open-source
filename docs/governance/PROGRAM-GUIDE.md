# FILE: PROGRAM-GUIDE.md


# PROGRAM-GUIDE.md

> 📘 This document outlines the overall structure, intent, and guiding principles of the NI Open-Source Program.

---

## §1. Why This Program Exists

The NI Open-Source Program enables NI and its community to collaborate on reusable IP that accelerates LabVIEW adoption and ecosystem health. By making high-impact components public, we:
- Improve trust and transparency
- Reduce duplication of effort
- Encourage broad-based innovation
- Enable partners and users to tailor NI tools to real-world needs

---

## §2. Program Lifecycle (3 Stages)

<!-- 🛠 FIX: Added SteerCo gating logic -->

### 🚀 Stage 3: Evaluation Complete
- A repository must have a **formed Steering Committee** before it becomes eligible for prioritization or NI investment
- SteerCo size and maturity are evaluated by the **Program Manager**
- Repos demonstrating commercial maturity may proceed without a SteerCo, at the Program Manager's discretion

---

## §3. What Makes a Repo a Good Candidate

- Must be usable and testable outside of NI-internal systems
- Should fill a documented user need (e.g., common protocol integration, scripting layer, test tooling)
- Has interest from external users or contributors
- Can be led by a non-NI technical Steering Committee

---

## §4. Contribution Agreements: DCO vs. CLA

<!-- 🛠 FIX: Clarified manual CLA tracking and future bot plans -->

For CLA-based repos:
- Contributions are currently reviewed **manually** by the Program Manager until GitHub bot enforcement is active
- Once deployed, the bot will retroactively validate prior CLA compliance

All CLA/DCO status changes must be documented publicly before enforcement

---

## §5. Revision History

| Date       | Summary                                      |
|------------|----------------------------------------------|
| 2025-05-22 | Added DCO vs. CLA logic to clarify contribution models |
| 2025-04-XX | Initial version                              |
