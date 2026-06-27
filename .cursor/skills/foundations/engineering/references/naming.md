# Naming

Names reveal responsibility. Use domain vocabulary consistently across features.

## File suffixes (this repo)

| Suffix | Meaning |
|---|---|
| `*_page.dart` | Routable screen |
| `*_provider.dart` | Riverpod providers / notifiers |
| `*_use_case.dart` | Domain business operation |
| `*_repository.dart` | Domain interface |
| `*_repository_impl.dart` | Firestore/data implementation |
| `*_dto.dart` | Firestore serialization |
| `app_*.dart` in `shared/widgets/` | App-wide reusable widget |

## Dart conventions

- Classes: `PascalCase`
- Files: `snake_case.dart` matching primary public type
- Providers: descriptive noun + `Provider` (`todayShiftsProvider`)
- Private widgets in pages: `_WidgetName` prefix

## Domain terms

Use consistently: **shift**, **companion**, **family member**, **unavailability**, **slot selection**, **coverage**.

Avoid mixing synonyms (e.g. "caregiver" vs "companion") unless the UI string requires it.
