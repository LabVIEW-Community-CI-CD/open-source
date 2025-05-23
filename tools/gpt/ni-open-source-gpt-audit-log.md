# NI Open-Source GPT – Governance Audit Log

This document tracks the configuration, source files, and behavioral scope of the NI Open-Source Governance GPT, used to support program-wide transparency and cross-stakeholder understanding.

---

## 📅 Initialization Date
2025-05-23

## 📘 GPT Name
**NI Open-Source Guide**

## 🧠 Purpose
To provide grounded answers about the NI Open-Source Program based on official documentation, supporting shared understanding across NI leadership, SteerCo, and the LabVIEW community.

## 📂 Governance Files Used as Sources

The following markdown files were uploaded to GPT Builder and serve as the sole knowledge base:

- `PROGRAM-GUIDE.md`
- `PRIORITY-SCORE.md`
- `STEERCO-GUIDELINES.md`
- `CONTRIBUTOR-RECOGNITION.md`
- `ENGAGEMENT-GUIDE.md`
- `MEETING-POLICY.md`
- `GOVERNANCE-CHANGELOG.md`

These were preprocessed to include clear sectioning, file headers, and GPT-readable formatting.

## 🧾 Prompt Instructions Used

The GPT is configured with:
- Explicit instructions to never speculate or go beyond the uploaded documentation
- Structured citation behavior (e.g., “See §2 in STEERCO-GUIDELINES.md”)
- Numbered follow-up suggestions to guide further exploration

## 🔁 Follow-Up Mode

The GPT always offers 3 numbered follow-up questions from an official list of 17 conversation starters. Users can type `1`, `2`, or `3` to continue the dialogue.

## 💬 Conversation Starters

Configured with 17 preloaded conversation starters covering:
- Prioritization
- Roles
- Certification
- Contributor behavior
- Meeting policy
- Process revision

## 🏷️ GPT Branding

- **Name**: NI Open-Source Guide
- **Icon**: 📘
- **Welcome Message**:
  > Welcome to the NI Open-Source Governance Advisor.  
  > Ask any question about contributor roles, repo prioritization, certification points, or Steering Committee participation.  
  > Type a number to explore common questions, or ask freely.

## 🔓 Visibility

This GPT is intended for public use (or limited stakeholder sharing), and is actively monitored for misinterpretation or unclear citations.

## 🛠 Maintainer

Program Manager: Sergio Velderrain  
Documentation Owner: [GitHub Repository – `/docs/governance`](https://github.com/ni/open-source/tree/main/docs/governance)

---
