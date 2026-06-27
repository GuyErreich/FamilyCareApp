---
name: family-care-wsl-dev
description: WSL2 + Cursor development environment for Family Care Scheduler. Use when configuring Flutter, Android SDK, environment variables, flutter doctor issues, adb, licenses, or running the app on WSL/Linux/Android from Windows-hosted SDK.
---

# Family Care WSL Dev Environment

## One source of truth for shell exports

All recurring variables live in **`~/.zshenv`** (not this skill). After editing:

```bash
source ~/.zshenv
```

The agent should update `~/.zshenv` when adding new tools — never ask the user to memorize exports.

## Current `~/.zshenv` template

```bash
# Flutter (https://docs.flutter.dev/install/manual)
export PATH="$HOME/flutter/bin:$PATH"
export PATH="$PATH:$HOME/.pub-cache/bin"

# Android SDK on Windows (hybrid WSL setup)
export ANDROID_HOME="/mnt/c/Users/user/AppData/Local/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# Java for sdkmanager / Gradle (WSL)
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$PATH"

# Chrome for flutter web (optional)
export CHROME_EXECUTABLE="/mnt/c/Program Files/Google/Chrome/Application/chrome.exe"
```

Adjust `user` if the Windows username differs.

## Architecture (WSL + Cursor + Android Studio)

| Component | Location |
|-----------|----------|
| Code, Flutter, Dart, tests | WSL (`~/Development/FamilyCareApp`) |
| Android SDK, emulator | Windows (`C:\Users\user\AppData\Local\Android\Sdk`) |
| Android Studio | Windows (Quail); can open `\\wsl$\Ubuntu-24.04\home\opsxe\...` |
| iOS builds | macOS only |

Do **not** use Homebrew for Flutter on WSL. Use official manual install to `~/flutter`.

## Windows SDK bridge scripts (WSL)

Windows SDK ships `.exe` only. WSL Flutter needs Unix names. Wrappers must exist at:

- `$ANDROID_HOME/platform-tools/adb` → `adb.exe`
- `$ANDROID_HOME/build-tools/<version>/aapt` → `aapt.exe`
- `$ANDROID_HOME/build-tools/<version>/aapt2` → `aapt2.exe`
- `$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager` → **Linux** binary (not cmd.exe wrapper)

Recreate `adb` wrapper if missing:

```bash
PT="$ANDROID_HOME/platform-tools"
cat > "$PT/adb" << 'EOF'
#!/usr/bin/env bash
exec "$(dirname "$0")/adb.exe" "$@"
EOF
chmod +x "$PT/adb"
```

## Common commands

```bash
source ~/.zshenv
cd ~/Development/FamilyCareApp
flutter doctor -v
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d linux          # works on WSL without Android
flutter run -d <android-id>   # after licenses + device/emulator
```

Project tasks: `task get`, `task gen`, `task test`, `task run` (see `Taskfile.yml`).

## flutter doctor checklist

| Issue | Fix |
|-------|-----|
| `adb` not found | Add `adb` wrapper (above) |
| `aapt` not found | Add `aapt`/`aapt2` wrappers in `build-tools/<version>/` |
| License status unknown | Linux `sdkmanager` + `yes \| flutter doctor --android-licenses`, or accept in Android Studio SDK Manager |
| Chrome not found | Set `CHROME_EXECUTABLE` in `~/.zshenv` (optional) |
| Android Studio not installed | Normal when Studio is on Windows only |

## Licenses (one-time)

```bash
cd ~
export ANDROID_HOME="/mnt/c/Users/user/AppData/Local/Android/Sdk"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
# Ensure Linux sdkmanager is in cmdline-tools/latest/bin (not .bat wrapper)
yes | flutter doctor --android-licenses
```

Or accept licenses in **Android Studio → SDK Manager** on Windows.

## Firebase (this project)

```bash
dart pub global activate flutterfire_cli
flutterfire configure   # after Firebase login
```

Placeholder config: `lib/firebase_options.dart` until `flutterfire configure` runs.

## When updating this skill

If new env vars or paths are added to the project, update **`~/.zshenv` first**, then sync the template section in this skill.
