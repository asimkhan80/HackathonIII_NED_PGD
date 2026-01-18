<!--
  ============================================================================
  SYNC IMPACT REPORT
  ============================================================================
  Version Change: 0.0.0 → 1.0.0 (MAJOR - initial constitution ratification)

  Modified Principles: N/A (initial version)

  Added Sections:
    - Article I: Purpose & Vision
    - Article II: Agent-First Development Mandate
    - Article III: Skills as the Primary Artifact
    - Article IV: MCP Code Execution Standard
    - Article V: Cross-Agent Portability
    - Article VI: Infrastructure & Cloud-Native Compliance
    - Article VII: LearnFlow Application Constraint
    - Article VIII: Autonomy & Measurability
    - Article IX: Repository Governance
    - Article X: Evaluation Alignment
    - Article XI: Amendment Clause

  Removed Sections: N/A (initial version)

  Templates Requiring Updates:
    - .specify/templates/plan-template.md ✅ (Constitution Check section compatible)
    - .specify/templates/spec-template.md ✅ (Requirements section compatible)
    - .specify/templates/tasks-template.md ✅ (Phase structure compatible)

  Follow-up TODOs: None
  ============================================================================
-->

# Hackathon III Constitution

**Reusable Intelligence and Cloud-Native Mastery**

## Core Principles

### I. Purpose & Vision

This constitution governs the design, development, and evaluation of all work produced during Hackathon III: Reusable Intelligence and Cloud-Native Mastery.

**Objective**: Shift software development from human-written code to agent-executed systems, where AI agents autonomously build, deploy, and verify cloud-native applications using reusable, measurable Skills.

**Core Vision**:
- Participants act as teachers of machines, not coders
- Humans define *how* work should be done; AI agents perform *the work itself*
- The Skill is the product
- Applications (e.g., LearnFlow) are evidence of Skill correctness

### II. Agent-First Development Mandate

**2.1 No Manual Application Coding**

Humans MUST NOT manually write:
- Application logic
- Infrastructure manifests
- Service code
- Deployment scripts

All such outputs MUST be produced by:
- Claude Code
- Goose

executing Skills with MCP Code Execution.

**2.2 Human Responsibilities (Allowed)**

Humans MAY:
- Design Skills
- Write SKILL.md
- Write REFERENCE.md
- Write scripts/ used by Skills
- Define specifications
- Define architecture
- Define validation criteria

Humans MUST NOT directly implement solutions.

### III. Skills as the Primary Artifact

**3.1 Definition of a Skill**

A Skill is a portable, agent-readable capability defined by:
- Minimal instructions (~100 tokens)
- Deterministic execution via scripts
- Clear validation criteria

**3.2 Mandatory Skill Structure**

Every Skill MUST follow:

```text
.claude/skills/<skill-name>/
├── SKILL.md
├── scripts/
│   └── executable code
└── REFERENCE.md (optional, deep docs)
```

**3.3 Token Efficiency Rule**

Skills MUST NOT:
- Load MCP servers directly into agent context
- Return large datasets into context

Skills MUST:
- Execute logic via scripts
- Return only minimal success/failure signals

### IV. MCP Code Execution Standard

**4.1 MCP Usage Constraint**

MCP servers MUST be treated as code APIs, not conversational tools.

Direct MCP tool calls inside agent context are PROHIBITED.

**4.2 Execution Pattern (Required)**

```text
Agent loads SKILL.md
       ↓
Agent executes script (outside context)
       ↓
Script interacts with MCP server
       ↓
Only minimal output returned
```

This pattern is non-negotiable.

### V. Cross-Agent Portability

**5.1 Compatibility Requirement**

Every Skill MUST function without modification on:
- Claude Code
- Goose

**5.2 Vendor Neutrality**

Skills MUST NOT:
- Depend on proprietary agent-specific syntax
- Assume a specific LLM provider

Skills MUST adhere to AAIF standards.

### VI. Infrastructure & Cloud-Native Compliance

**6.1 Kubernetes Mandate**

All runtime systems MUST:
- Run on Kubernetes (Minikube locally)
- Be containerized
- Be declaratively deployed

**6.2 Required Stack Usage**

The following MUST be demonstrated via Skills:

| Layer | Requirement |
|-------|-------------|
| Orchestration | Kubernetes |
| Messaging | Kafka |
| Service Runtime | Dapr |
| Backend | FastAPI |
| Frontend | Next.js |
| Database | PostgreSQL |
| AI Context | MCP Servers |
| CD | Argo CD (bonus but expected) |

### VII. LearnFlow Application Constraint

**7.1 Role of LearnFlow**

LearnFlow is NOT the product.

LearnFlow exists to:
- Validate Skill correctness
- Demonstrate autonomous agent execution
- Prove reusability of Skills

**7.2 Build Rule**

The LearnFlow application MUST be built:
- Entirely by agents
- Using only participant-authored Skills

Manual fixes are DISALLOWED.

### VIII. Autonomy & Measurability

**8.1 Autonomy Requirement**

A Skill is valid ONLY if:
- A single natural-language prompt
- Results in a working, verified outcome
- Without human intervention

**8.2 Validation**

Each Skill MUST define:
- Explicit success criteria
- Deterministic verification steps

### IX. Repository Governance

**9.1 Required Repositories**

**Repository 1 — skills-library**

Contains:
- All Skills
- No application code
- Documentation explaining Skill design

**Repository 2 — learnflow-app**

Contains:
- Agent-generated application output
- Agent-generated commits
- Evidence of Skill usage

**9.2 Commit History Rule**

Commit messages MUST reflect agent authorship:

```text
Claude: deployed Kafka using kafka-k8s-setup skill
Goose: generated FastAPI service via fastapi-dapr-agent skill
```

## Evaluation Alignment

This constitution aligns with Gold-Standard evaluation:

| Criterion | Constitutional Coverage |
|-----------|------------------------|
| Skills Autonomy | Articles II, VIII |
| Token Efficiency | Articles III, IV |
| Cross-Agent Compatibility | Article V |
| Architecture Correctness | Articles VI, VII |
| MCP Integration | Article IV |
| Documentation | Articles III, IX |
| Spec-Driven Development | Articles I, II |

## Governance

### Amendment Clause

This constitution MAY be amended ONLY if:
- Changes increase autonomy
- Reduce token usage
- Improve portability
- Strengthen Skill reusability

Any amendment MUST be documented as a Skill evolution.

### Versioning Policy

- **MAJOR**: Backward incompatible governance/principle removals or redefinitions
- **MINOR**: New principle/section added or materially expanded guidance
- **PATCH**: Clarifications, wording, typo fixes, non-semantic refinements

### Compliance Review

- All PRs/reviews MUST verify compliance with this constitution
- Complexity MUST be justified against the principles herein
- Skills MUST pass autonomy and portability validation before merge

**Version**: 1.0.0 | **Ratified**: 2025-01-18 | **Last Amended**: 2025-01-18
