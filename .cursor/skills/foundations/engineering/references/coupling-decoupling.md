# Coupling & Decoupling

- **Couple** modules that always change together (e.g. shift entity + shift DTO field renames).
- **Decouple** modules that change for different reasons (e.g. calendar painter vs shift repository).
- **Avoid** both duplication and premature abstraction.

## Flutter-specific

- Presentation depends on domain interfaces and Riverpod providers — not on `FirebaseFirestore` directly.
- `infinite_calendar_view` stays behind `FamilySchedulePlanner` / `FamilyScheduleMonth` — feature pages do not import the package.
- Theme tokens live in `AppTheme` / `AppMotion` — widgets read `Theme.of(context)`, not hardcoded colors.

When two features need the same data, share a provider in domain or `core/providers/`, not a cross-feature widget import.
