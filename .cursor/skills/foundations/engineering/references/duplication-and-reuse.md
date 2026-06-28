# Duplication & Reuse

One implementation, imported everywhere. Duplicated logic drifts.

## Identifying duplication

- Identical or near-identical functions where only a constant or label differs.
- The same orchestration, validation, or transformation in two modules.
- The same component shell repeated with small variations.
- The same CSS pattern, hook shape, or Supabase query in 2+ files.

Coincidental similarity is not duplication. Two blocks that change for different reasons stay separate.

## Extraction targets (this repo)

| Repeated thing | Extract to |
|---|---|
| Pure logic | `web/src/lib/` or domain-specific utility |
| Stateful orchestration | Custom hook in `web/src/hooks/` |
| Component shell | `web/src/components/ui/common/` or domain folder |
| Visual tokens | CSS variables in `web/src/styles/base.css` |
| Supabase mapping | Typed helpers in `web/src/lib/` or domain hooks |

## Rule of thumb

Extract on the **second** occurrence, in the same change. Exception: user explicitly requests a minimal one-off patch.

## Before creating anything new

1. Search `web/src/components/ui/common/`, `web/src/lib/`, and the current feature folder.
2. If found in more than one place, extract immediately.
