# Family Care Scheduler

Coordinate who accompanies Grandpa throughout the day. Minimize scheduling conflicts, send reminders, and sync with Google Calendar.

## Prerequisites

- Flutter stable (3.44+) — [manual Linux install](https://docs.flutter.dev/install/manual)
- Firebase CLI (`npm install -g firebase-tools` or `npx firebase-tools@latest`)
- Android Studio on **Windows** for Android builds; Xcode on macOS for iOS builds

### WSL + Cursor (this project)

This repo is developed in **WSL2** with **Cursor**. Flutter is installed manually to `~/flutter` (not Homebrew).

**Shell environment** — all exports live in `~/.zshenv`:

```bash
source ~/.zshenv   # or open a new terminal
```

See `.cursor/skills/family-care-wsl-dev/SKILL.md` for Android SDK wrappers, licenses, WSL memory, and troubleshooting.

**Cursor tip:** Open the folder via WSL (`\\wsl$\Ubuntu\home\opsxe\Development\FamilyCareApp`) so the integrated terminal uses your WSL `flutter` from `~/.zshenv`.

**WSL memory:** Flutter builds are heavy. Set `C:\Users\user\.wslconfig` to at least `memory=8GB`, then `wsl --shutdown`. Run `flutter` / `task run` in an **external** terminal if Cursor disconnects from WSL.

**Platform notes:**

| Target | Where to build |
|--------|----------------|
| Android | WSL + Windows Android Studio SDK + emulator |
| iOS | macOS only |

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

Project: `family-care-scheduler-dev` (see `.firebaserc`).

1. Enable **Authentication** (Google, Email/Password).
2. Create a **Firestore** database.
3. Enable **Cloud Messaging**.
4. `flutterfire configure` needs the **`firebase` CLI on PATH** (`npm install -g firebase-tools`).

Android/iOS apps are registered; `android/app/google-services.json` and `lib/firebase_options.dart` are configured.

### Local emulators (optional)

```bash
npx -y firebase-tools@latest emulators:start
```

## Run

This app targets **Android and iOS only** (no linux/web folders). Start an Android emulator in Windows Android Studio, then:

```bash
adb devices
flutter run -d <android-device-id>   # or: task run
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
| `unavailabilities` | App-only companion unavailability blocks |
| `notifications` | In-app notification records |
| `settings` | Per-user or per-family preferences (incl. coverage fallback order) |

## Commands

See `Taskfile.yml` for common tasks (`task install`, `task gen`, `task test`, `task analyze`, `task all`, `task run`).

## Testing

```bash
flutter test
flutter analyze
```
