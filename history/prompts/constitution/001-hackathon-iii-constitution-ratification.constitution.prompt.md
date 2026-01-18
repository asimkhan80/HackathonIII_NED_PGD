---
id: 001
title: Hackathon III Constitution Ratification
stage: constitution
date: 2025-01-18
surface: agent
model: claude-opus-4-5-20251101
feature: none
branch: master
user: Asim
command: /sp.constitution
labels: ["constitution", "hackathon-iii", "agent-first", "skills", "cloud-native"]
links:
  spec: null
  ticket: null
  adr: null
  pr: null
files:
  - .specify/memory/constitution.md
tests:
  - N/A (governance document)
---

## Prompt

Article I — Purpose & Vision
1.1 Purpose

This constitution governs the design, development, and evaluation of all work produced during Hackathon III: Reusable Intelligence and Cloud-Native Mastery.

The objective is to shift software development from human-written code to agent-executed systems, where AI agents autonomously build, deploy, and verify cloud-native applications using reusable, measurable Skills.

1.2 Core Vision

Participants act as teachers of machines, not coders.

Humans define how work should be done
AI agents perform the work itself

The Skill is the product.
Applications (e.g., LearnFlow) are evidence of Skill correctness.

Article II — Agent-First Development Mandate
2.1 No Manual Application Coding

Humans MUST NOT manually write:

Application logic

Infrastructure manifests

Service code

Deployment scripts

All such outputs MUST be produced by:

Claude Code

Goose
executing Skills with MCP Code Execution

2.2 Human Responsibilities (Allowed)

Humans may:

Design Skills

Write SKILL.md

Write REFERENCE.md

Write scripts/ used by Skills

Define specifications

Define architecture

Define validation criteria

Humans may not directly implement solutions.

Article III — Skills as the Primary Artifact
3.1 Definition of a Skill

A Skill is a portable, agent-readable capability defined by:

Minimal instructions (~100 tokens)

Deterministic execution via scripts

Clear validation criteria

3.2 Mandatory Skill Structure

Every Skill MUST follow:

.claude/skills/<skill-name>/
├── SKILL.md
├── scripts/
│   └── executable code
└── REFERENCE.md (optional, deep docs)

3.3 Token Efficiency Rule

Skills MUST NOT:

Load MCP servers directly into agent context

Return large datasets into context

Skills MUST:

Execute logic via scripts

Return only minimal success/failure signals

Article IV — MCP Code Execution Standard
4.1 MCP Usage Constraint

MCP servers MUST be treated as code APIs, not conversational tools.

Direct MCP tool calls inside agent context are prohibited.

4.2 Execution Pattern (Required)
Agent loads SKILL.md
↓
Agent executes script (outside context)
↓
Script interacts with MCP server
↓
Only minimal output returned


This pattern is non-negotiable.

Article V — Cross-Agent Portability
5.1 Compatibility Requirement

Every Skill MUST function without modification on:

Claude Code

Goose

5.2 Vendor Neutrality

Skills MUST NOT:

Depend on proprietary agent-specific syntax

Assume a specific LLM provider

Skills MUST adhere to AAIF standards.

Article VI — Infrastructure & Cloud-Native Compliance
6.1 Kubernetes Mandate

All runtime systems MUST:

Run on Kubernetes (Minikube locally)

Be containerized

Be declaratively deployed

6.2 Required Stack Usage

The following MUST be demonstrated via Skills:

Layer    Requirement
Orchestration    Kubernetes
Messaging    Kafka
Service Runtime    Dapr
Backend    FastAPI
Frontend    Next.js
Database    PostgreSQL
AI Context    MCP Servers
CD    Argo CD (bonus but expected)

Article VII — LearnFlow Application Constraint
7.1 Role of LearnFlow

LearnFlow is not the product.

LearnFlow exists to:

Validate Skill correctness

Demonstrate autonomous agent execution

Prove reusability of Skills

7.2 Build Rule

The LearnFlow application MUST be built:

Entirely by agents

Using only participant-authored Skills

Manual fixes are disallowed.

Article VIII — Autonomy & Measurability
8.1 Autonomy Requirement

A Skill is valid only if:

A single natural-language prompt

Results in a working, verified outcome

Without human intervention

8.2 Validation

Each Skill MUST define:

Explicit success criteria

Deterministic verification steps

Article IX — Repository Governance
9.1 Required Repositories
Repository 1 — skills-library

Contains:

All Skills

No application code

Documentation explaining Skill design

Repository 2 — learnflow-app

Contains:

Agent-generated application output

Agent-generated commits

Evidence of Skill usage

9.2 Commit History Rule

Commit messages MUST reflect agent authorship:

Claude: deployed Kafka using kafka-k8s-setup skill
Goose: generated FastAPI service via fastapi-dapr-agent skill

Article X — Evaluation Alignment

This constitution aligns with Gold-Standard evaluation:

Criterion    Constitutional Coverage
Skills Autonomy    Articles II, VIII
Token Efficiency    Articles III, IV
Cross-Agent Compatibility    Article V
Architecture Correctness    Articles VI, VII
MCP Integration    Article IV
Documentation    Articles III, IX
Spec-Driven Development    Articles I, II

Article XI — Amendment Clause

This constitution may be amended only if:

Changes increase autonomy

Reduce token usage

Improve portability

Strengthen Skill reusability

Any amendment must be documented as a Skill evolution.

## Response snapshot

Created Hackathon III Constitution v1.0.0 with 11 articles governing agent-first development:

1. **Purpose & Vision** - Defines objective to shift from human-written to agent-executed systems
2. **Agent-First Development Mandate** - Prohibits manual application coding; humans design Skills only
3. **Skills as Primary Artifact** - Defines Skill structure (~100 tokens, scripts, validation)
4. **MCP Code Execution Standard** - Requires script-based MCP interaction pattern
5. **Cross-Agent Portability** - Skills MUST work on Claude Code and Goose
6. **Infrastructure & Cloud-Native Compliance** - Kubernetes, Kafka, Dapr, FastAPI, Next.js, PostgreSQL stack
7. **LearnFlow Application Constraint** - App exists only to validate Skills; no manual fixes
8. **Autonomy & Measurability** - Single prompt → working outcome without intervention
9. **Repository Governance** - skills-library + learnflow-app repositories required
10. **Evaluation Alignment** - Maps to Gold-Standard criteria
11. **Amendment Clause** - Changes only if they increase autonomy/portability/reusability

Templates validated as compatible. No follow-up actions required.

## Outcome

- Impact: Initial constitution ratification establishing governance framework for Hackathon III
- Tests: N/A (governance document)
- Files: .specify/memory/constitution.md created (v1.0.0)
- Next prompts: Define first Skill, create skills-library repo structure
- Reflection: Comprehensive 11-article constitution captures all agent-first development principles

## Evaluation notes (flywheel)

- Failure modes observed: None
- Graders run and results (PASS/FAIL): Manual review PASS - all placeholders filled, all articles captured
- Prompt variant (if applicable): N/A
- Next experiment (smallest change to try): N/A
