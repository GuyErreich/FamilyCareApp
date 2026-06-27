---
name: family-care-flutter
description: Flutter conventions for Family Care Scheduler. Use when adding features, Riverpod providers, GoRouter routes, freezed models, or reviewing architecture in lib/.
---

# Family Care Flutter

## Architecture

- Feature-first: `lib/features/<name>/{data,domain,presentation}/`
- No business logic in widgets — use use-cases via Riverpod notifiers.
- Repository interfaces in domain; implementations in data.

## Riverpod

- `Provider` for dependencies (repositories, Firebase).
- `StreamProvider` / `FutureProvider` for read-only async data.
- `Notifier` / `AsyncNotifier` for mutable feature state.

## Models

- Domain entities: freezed in `domain/entities/`
- Firestore DTOs: freezed + json_serializable in `data/dto/`
- Run `dart run build_runner build --delete-conflicting-outputs` after changes.

## Routing

- Routes defined in `core/router/app_router.dart`
- Auth redirects: login → onboarding → shell

## Naming

- Pages: `*_page.dart`
- Providers: `*_provider.dart`
- Use-cases: `*_use_case.dart`
