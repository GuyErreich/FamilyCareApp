---
name: engineering
description: Universal software engineering foundation — duplication, typing intent, naming, folder structure, separation of concerns, and coupling discipline. Base skill every other code skill extends. Use before writing or reviewing any code in this repo.
disable-model-invocation: true
---

# Engineering Foundations

Language-agnostic principles that every `platform/` and `project/` skill assumes. This skill owns the *why*; downstream skills own the *how* for their domain.

**Load this first**, then layer the domain skill on top.

## Principles

| Principle | Rule | Deep detail |
|---|---|---|
| No duplication | Same logic, structure, or pattern in 2+ places → extract before adding a third copy | `references/duplication-and-reuse.md` |
| Proper typings | Explicit types at boundaries; types document intent; never hide design gaps | `references/typing-discipline.md` |
| Proper naming | Names reveal responsibility; consistent domain vocabulary | `references/naming.md` |
| Folder structure | Organize by feature/responsibility; shared vs feature-local obvious from path | `references/folder-structure.md` |
| Separation of concerns | One module, one reason to change; data, orchestration, presentation, I/O apart | `references/separation-of-concerns.md` |
| Coupling / decoupling | Couple what changes together; decouple what changes for different reasons | `references/coupling-decoupling.md` |

## Workflow

1. **Search before creating.** Look for existing module, helper, type, or component that already covers the need.
2. **Decide the boundary first.** State where shared logic, feature-local logic, and composition each live.
3. **Write to the principles above.** Keep each unit single-responsibility.
4. **Extract on the second occurrence.** When a pattern repeats, extract in the same change.
5. **Validate.** Run `task web:check` before considering the change done.

## When to load references

Load a `references/` file only when a principle needs a decision you cannot make from the table — e.g. true duplication vs coincidental similarity. Do not preload.

## Inheritance contract

Every skill under `platform/` and `project/` opens with `## Extends` pointing here and must not contradict these principles. Project skills may tighten rules; never loosen them.
