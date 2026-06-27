# UI Extraction Triggers (Flutter)

Extract shared UI immediately when any of these occur:

- The same widget subtree appears in 2+ pages.
- The same `BoxDecoration`, border, or painter logic is copied.
- The same provider wiring + `Column`/`ListView` shell repeats.
- A page mixes data orchestration and layout beyond comfortable reading.

## Extraction targets

| Repeated thing | Extract to |
|---|---|
| Widget subtree | `lib/shared/widgets/` or `presentation/widgets/` |
| Visual tokens / painters | `*_style.dart` or `lib/core/theme/` |
| Async loading shell | `AsyncValueWidget` or feature wrapper |
| Form sections | Dedicated widget in `presentation/` |

## Default enforcement

- When a change touches duplicated UI or styling, extraction is part of the same change.
- Do not ship visual parity while duplicate logic remains elsewhere.
- Skip only when the user explicitly requests a minimal one-off patch.

## Prefer theme over literals

Use `colorScheme`, `textTheme`, and shared style classes. Reserve inline `Color(0x...)` for member-specific shift colors from Firestore.
