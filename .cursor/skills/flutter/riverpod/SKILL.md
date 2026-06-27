---
name: flutter-riverpod
description: Riverpod patterns for Family Care Scheduler — Provider, StreamProvider, AsyncNotifier, and AsyncValue UI. Use when adding or refactoring providers in lib/. Extends flutter-architecture.
disable-model-invocation: true
---

# Riverpod

## Extends

Load `foundations/engineering` then `flutter/architecture` first.

## Provider types

| Type | Use for |
|---|---|
| `Provider` | Repositories, services, `GoRouter`, Firebase instances |
| `StreamProvider` / `FutureProvider` | Read-only async data (shifts stream, family members) |
| `Notifier` / `AsyncNotifier` | Mutable feature state with explicit methods |
| `.family` | Parameterized streams (`dayShiftsProvider(day)`) |

## UI contract

- Pages use `ref.watch` in `build`; side effects use `ref.listen` or notifiers
- Wrap async UI in `AsyncValueWidget` or `.when()` — always handle loading and error
- Do not read repositories directly from widgets; go through providers or use-cases

## Patterns

```dart
// Dependency
final shiftRepositoryProvider = Provider<ShiftRepository>((ref) => ...);

// Stream
final todayShiftsProvider = StreamProvider<List<Shift>>((ref) { ... });

// Listen for side effects (snackbars, navigation)
ref.listen<int>(scheduleDaysShowedProvider, (prev, next) { ... });
```

## Anti-patterns

- `setState` to mirror provider data
- Creating `ProviderContainer` in widgets (only in `main.dart` bootstrap if needed)
- Business validation inside `StreamProvider` builder — use use-case instead
