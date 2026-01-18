# Skills Library

This directory contains all reusable Skills for Hackathon III: Reusable Intelligence and Cloud-Native Mastery.

## Constitution Compliance

All Skills in this library MUST comply with the [Hackathon III Constitution](../../.specify/memory/constitution.md):

- **Article III**: Skills as Primary Artifact (~100 tokens, scripts, validation)
- **Article IV**: MCP Code Execution Standard (script-based, minimal output)
- **Article V**: Cross-Agent Portability (Claude Code + Goose compatible)
- **Article VIII**: Autonomy & Measurability (single prompt → verified outcome)

## Skill Structure

```
.claude/skills/<skill-name>/
├── SKILL.md           # Minimal instructions (~100 tokens) - REQUIRED
├── scripts/           # Executable code - REQUIRED
│   └── *.sh|*.py|*.js
└── REFERENCE.md       # Deep documentation - OPTIONAL
```

## Creating a New Skill

1. Copy the template:
   ```bash
   cp -r .claude/skills/_skill-template .claude/skills/my-new-skill
   ```

2. Edit `SKILL.md` with:
   - Purpose (one sentence)
   - Usage (natural language prompt)
   - Execution command
   - Inputs/Outputs
   - Validation steps

3. Implement scripts in `scripts/`

4. Test with both Claude Code and Goose

## Available Skills

| Skill | Purpose | Status |
|-------|---------|--------|
| `_skill-template` | Template for new skills | Template |

## Token Efficiency Rules

Skills MUST NOT:
- Load MCP servers directly into agent context
- Return large datasets into context

Skills MUST:
- Execute logic via scripts (outside agent context)
- Return only minimal success/failure signals

## Execution Pattern

```
Agent loads SKILL.md
       ↓
Agent executes script (outside context)
       ↓
Script interacts with MCP server (if needed)
       ↓
Only minimal output returned (SUCCESS/FAILURE)
```

## Validation Checklist

Before merging a Skill:

- [ ] SKILL.md is under ~100 tokens
- [ ] Scripts execute without errors
- [ ] Works on Claude Code
- [ ] Works on Goose
- [ ] Returns minimal output signals
- [ ] Validation steps are deterministic
