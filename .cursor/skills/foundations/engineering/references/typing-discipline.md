# Typing Discipline (Dart)

- Explicit types on public APIs, repository methods, and use-case inputs/outputs.
- Freezed for immutable domain entities and Firestore DTOs.
- `Result<T>` / `AsyncValue<T>` at boundaries — do not swallow errors as `null` without intent.
- Avoid `dynamic` and unchecked casts from `event.data` — pattern-match or type-guard first.

Types document intent. If a type feels wrong, fix the design before adding `?` or `as`.
