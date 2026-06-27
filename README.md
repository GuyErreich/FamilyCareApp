# Family Care Scheduler

Coordinate who accompanies Grandpa throughout the day. Minimize scheduling conflicts, send reminders, and sync with Google Calendar.

## Prerequisites

- Flutter stable (3.44+)
- Firebase CLI (`npx -y firebase-tools@latest`)
- Android Studio / Xcode for mobile targets

## Setup

```bash
# Install dependencies
flutter pub get

# Generate freezed / json_serializable / riverpod code
dart run build_runner build --delete-conflicting-outputs

# Configure Firebase (after creating a Firebase project)
flutterfire configure
```

### Firebase

1. Create a Firebase project or use `family-care-scheduler-dev`.
2. Enable **Authentication** (Google, Email/Password).
3. Create a **Firestore** database.
4. Enable **Cloud Messaging**.
5. Run `flutterfire configure` to replace placeholder values in `lib/firebase_options.dart`.

### Local emulators (optional)

```bash
npx -y firebase-tools@latest emulators:start
```

## Run

```bash
flutter run
```

## Architecture

Feature-first clean architecture:

```
lib/
  core/           # theme, router, providers, utils
  features/       # auth, shifts, dashboard, calendar, family, ...
  shared/         # reusable widgets
```

Each feature has `data/`, `domain/`, and `presentation/` layers.

## Firestore Collections

| Collection | Purpose |
|------------|---------|
| `families` | Family group metadata and invite codes |
| `users` | App user profiles linked to a family |
| `familyMembers` | Members who can be assigned shifts |
| `shifts` | Companion shift schedule |
| `notifications` | In-app notification records |
| `settings` | Per-user or per-family preferences |

## Commands

See `Taskfile.yml` for common tasks (`task run`, `task test`, `task gen`, `task analyze`).

## Testing

```bash
flutter test
flutter analyze
```
