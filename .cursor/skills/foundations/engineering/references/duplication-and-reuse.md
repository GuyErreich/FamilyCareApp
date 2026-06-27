# Duplication & Reuse

One implementation, imported everywhere. Duplicated logic drifts.

## Identifying duplication

- Identical or near-identical functions where only a constant or label differs.
- The same orchestration, validation, or transformation in two modules.
- The same widget shell repeated with small variations.
- The same `BoxDecoration`, painter logic, or Riverpod provider shape in 2+ files.

Coincidental similarity is not duplication. Two blocks that change for different reasons stay separate.

## Extraction targets (this repo)

| Repeated thing | Extract to |
|---|---|
| Pure logic | `lib/core/utils/` or feature `domain/` use-case |
| Stateful orchestration | Riverpod notifier/provider in `*_provider.dart` |
| Widget shell | `lib/shared/widgets/` or feature `presentation/widgets/` |
| Visual tokens | `lib/core/theme/` or feature style module (e.g. `schedule_calendar_style.dart`) |
| Firestore mapping | DTO + repository method in `data/` |

## Rule of thumb

Extract on the **second** occurrence, in the same change. Exception: user explicitly requests a minimal one-off patch.

## Before creating anything new

1. Search `lib/shared/widgets/`, `lib/core/`, and the current feature folder.
2. If found in more than one place, extract immediately.
