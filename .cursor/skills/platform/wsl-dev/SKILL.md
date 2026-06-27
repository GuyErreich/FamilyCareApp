---
name: wsl-dev
description: WSL2 + Cursor development environment for Family Care Scheduler. Use when configuring Flutter, Android SDK, environment variables, flutter doctor issues, adb, licenses, or running the app on WSL/Linux/Android from Windows-hosted SDK.
disable-model-invocation: true
---

# WSL Dev Environment

## Extends

Load `foundations/engineering` when changing project tooling or Taskfile — not required for pure env troubleshooting.

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

# NVM (firebase CLI via npm global — required for flutterfire configure)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
```

Adjust `user` if the Windows username differs.

## WSL memory (Cursor disconnects)

Flutter/Gradle can OOM WSL (~4GB default) and disconnect Cursor. Fix on Windows:

`C:\Users\user\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
swap=4GB
```

Then: `wsl --shutdown` and reopen Cursor.

Run heavy `flutter` / `task run` commands in an **external** Windows Terminal tab when possible.

## Architecture (WSL + Cursor + Android Studio)

| Component | Location |
|-----------|----------|
| Code, Flutter, Dart, tests | WSL (`~/Development/FamilyCareApp`) |
| Android SDK, emulator | Windows (`C:\Users\user\AppData\Local\Android\Sdk`) |
| Android Studio | Windows; open `\\wsl$\Ubuntu\home\opsxe\...` |
| iOS builds | macOS only |

Do **not** use Homebrew for Flutter on WSL. Use official manual install to `~/flutter`.

This Flutter project has **android + ios only** — not linux/web. `flutter run` without an Android device fails.

## Windows SDK bridge scripts (WSL)

Windows SDK ships `.exe` only. WSL Flutter needs Unix names. Wrappers must exist at:

- `$ANDROID_HOME/platform-tools/adb` → `adb.exe`
- `$ANDROID_HOME/build-tools/<version>/aapt` → `aapt.exe`
- `$ANDROID_HOME/build-tools/<version>/aapt2` → `aapt2.exe`
- `$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager` → **Linux** binary (not cmd.exe wrapper)

Recreate wrappers for each installed build-tools version (e.g. `36.1.0`, `37.0.0`):

```bash
PT="$ANDROID_HOME/platform-tools"
cat > "$PT/adb" << 'EOF'
#!/usr/bin/env bash
exec "$(dirname "$0")/adb.exe" "$@"
EOF
chmod +x "$PT/adb"

BT="$ANDROID_HOME/build-tools/37.0.0"   # repeat for each version
for tool in aapt aapt2; do
  cat > "$BT/$tool" << EOF
#!/usr/bin/env bash
exec "\$(dirname "\$0")/${tool}.exe" "\$@"
EOF
  chmod +x "$BT/$tool"
done
```

## Common commands

```bash
source ~/.zshenv
cd ~/Development/FamilyCareApp
task test        # safe in Cursor — no Gradle
task analyze
adb devices
flutter run -d <android-id>   # use external terminal if Cursor disconnects
```

Project tasks: `task get`, `task gen`, `task all` (see `Taskfile.yml`).

## flutter doctor checklist

| Issue | Fix |
|-------|-----|
| `adb` not found | Add `adb` wrapper (above) |
| `aapt` not found | Add `aapt`/`aapt2` wrappers per build-tools version |
| License status unknown | Linux `sdkmanager` + `yes \| flutter doctor --android-licenses`, or accept in Android Studio |
| Chrome not found | Set `CHROME_EXECUTABLE` in `~/.zshenv` (optional) |
| Cursor disconnects on flutter | Increase WSL memory; run flutter externally |
| Emulator time / timezone wrong | See **Emulator timezone** below |

## Emulator timezone

The Android emulator has its **own** clock — it does not automatically match WSL or Windows. `DateTime.now()` in the app uses the emulator timezone.

```bash
adb shell getprop persist.sys.timezone
adb shell date
```

**Option A — Android Studio:** Emulator **⋯** → **Settings** → **Time zone** → pick region. Cold boot if needed.

**Option B — ADB:**

```bash
adb shell setprop persist.sys.timezone Europe/London
adb shell am broadcast -a android.intent.action.TIMEZONE_CHANGED
```

## Firebase (this project)

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project=family-care-scheduler-dev --platforms=android,ios --yes
```

Configured: `family-care-scheduler-dev`, `lib/firebase_options.dart`, `android/app/google-services.json`.

## When updating this skill

Update **`~/.zshenv` first**, then sync the template section here.
