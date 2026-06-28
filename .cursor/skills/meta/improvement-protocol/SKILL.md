---
name: improvement-protocol
description: Flags and implements improvements to Family Care Scheduler skills, rules, and agent instructions. Use when discovering patterns that should be documented or when updating `.cursor/skills/` or `.cursor/rules/`.
disable-model-invocation: true
---

# Improvement Protocol

When a new improvement is discovered during development or review, flag it before implementation. Non-blocking improvements go in **separate parallel sessions**.

## When to flag

- Code pattern or rule would benefit the project if documented
- Existing instruction is incomplete or outdated
- New architectural or UI pattern should be standardized
- Skill or rule in `.cursor/skills/` or `.cursor/rules/` needs expansion

## Flag template

```markdown
🔧 IMPROVEMENT FLAGGED:

**Category:** [Skills | Rules | AGENTS.md]
**Target File:** [path/to/SKILL.md or .mdc]
**Title:** [Concise name]
**Description:** [What to add/change and why]
**Scope:** [Single file | Multiple files | New file]
**Estimated Effort:** [Quick | Medium | Complex]
**Priority:** [Nice-to-have | Recommended | Critical]
```

## Process

1. **Pause** and flag explicitly with context
2. **Ask:** implement now, parallel session (recommended), or skip
3. **Parallel session:** read target file, draft, implement, validate (`task web:check`), report back
4. Main session continues uninterrupted

## Good vs skip

**Good:** pattern appears 2+ times, clarifies ambiguity, standardizes naming, documents edge cases (Firestore rules, planner painters, shared widgets)

**Skip:** one-off workaround, contradicts existing architecture, massive refactor, speculative features

## Target files

- `.cursor/rules/**/*.mdc` — always-applied and glob rules
- `.cursor/skills/**/SKILL.md` — portable and project skills
- `AGENTS.md` — entry point and commands
- `README.md` — setup and schema (via `project/docs` skill)

Keep `foundations/` skills free of one-off project paths; project-specific paths belong in `project/` or `platform/`.
