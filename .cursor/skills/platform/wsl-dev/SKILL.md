---
name: wsl-dev
description: WSL2 + Cursor development environment for Family Care Scheduler. Use when configuring Node.js, environment variables, WSL memory issues, or running the web app and Supabase stack from WSL.
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
# Node.js via NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Supabase CLI (if not on default PATH)
# export PATH="$HOME/.local/bin:$PATH"
```

Adjust paths if your install differs.

## WSL memory (Cursor disconnects)

Heavy builds can OOM WSL (~4GB default) and disconnect Cursor. Fix on Windows:

`C:\Users\user\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
swap=4GB
```

Then: `wsl --shutdown` and reopen Cursor.

Run heavy `npm run build` / `task web:build` in an **external** Windows Terminal tab when possible.

## Architecture (WSL + Cursor)

| Component | Location |
|-----------|----------|
| Code, Node, tests | WSL (`~/Development/FamilyCareApp`) |
| Supabase local stack | WSL via `supabase start` |
| Cloudflare deploy | WSL via `task deploy:pages` |

## Common commands

```bash
source ~/.zshenv
cd ~/Development/FamilyCareApp
task web:dev          # Vite dev server
task web:check        # lint, test, build
task supabase:start   # local Postgres + Auth
```

Project tasks: see `Taskfile.yml` and `AGENTS.md`.

## When updating this skill

Update **`~/.zshenv` first**, then sync the template section here.
