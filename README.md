# Family Care Scheduler

Coordinate who accompanies Grandpa throughout the day. Minimize scheduling conflicts, send reminders, and sync with Google Calendar.

**Stack:** Vite + React + TypeScript PWA on Cloudflare Pages, with Supabase (Postgres, Auth, Realtime, Edge Functions).

## Prerequisites

- Node.js 20+
- [Supabase CLI](https://supabase.com/docs/guides/cli)
- Optional: [Wrangler CLI](https://developers.cloudflare.com/workers/wrangler/) for Cloudflare Pages deploy

## Setup

### 1. Supabase (local)

```bash
supabase start
```

Apply migrations from `supabase/migrations/`. Local API URL and anon key are printed by `supabase start`.

#### Google login + Calendar sync (recommended)

One **Google Cloud project** (`family-care-scheduler-dev`) covers both features. You are not hosting on GCP — only registering OAuth and enabling the Calendar API (~$0 at family scale).

**Architecture:**

```
Login page  → Supabase Auth → Google (email/profile)     → session in app
Settings    → Supabase Auth → Google (+ calendar scope) → provider_token → Calendar API
Shift save  → browser calls googleapis.com/calendar/v3 with that token
```

##### A. Google Cloud Console (once)

Project: [family-care-scheduler-dev](https://console.cloud.google.com/?project=family-care-scheduler-dev)

1. **Enable Calendar API**  
   [Calendar API → Enable](https://console.cloud.google.com/apis/library/calendar-json.googleapis.com?project=family-care-scheduler-dev)

2. **Google Auth Platform** (APIs & Services → OAuth consent screen)  
   - User type: **External** (or Internal if Workspace)  
   - **Data Access** → add scopes: `email`, `profile`, `openid`, and **`https://www.googleapis.com/auth/calendar`**  
   - **Audience** → stay in **Testing** for private/family use; add family Gmail addresses under **Test users**  
   - For Production and Google verification requirements, see **[docs/google-oauth.md](docs/google-oauth.md)**

3. **OAuth 2.0 Client ID** (Credentials → Web application)  
   Reuse existing Web client or create one.

   | Field | Local dev | Production |
   |-------|-----------|------------|
   | **Authorized redirect URIs** | `http://127.0.0.1:54321/auth/v1/callback` | `https://<project-ref>.supabase.co/auth/v1/callback` |
   | **Authorized JavaScript origins** | `http://localhost:5173`, `http://localhost:5174`, `http://127.0.0.1:5173` | `https://your-app.pages.dev` |

   Copy **Client ID** and **Client secret**.

##### B. Supabase (local)

Edit `supabase/.env` (Web client ID is pre-filled):

```bash
SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=388117547421-fufsuan14l8gb8sr07cmc8apb1kvto9o.apps.googleusercontent.com
SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET=paste-secret-here
```

Restart: `supabase stop && supabase start`

Google is enabled in `supabase/config.toml` under `[auth.external.google]`.

##### C. Supabase (hosted / production)

1. Dashboard → **Authentication → Providers → Google** → enable, paste Client ID + Secret  
2. **Authentication → URL configuration** → add Site URL + Redirect URLs for your Cloudflare Pages domain  
3. Same Google OAuth client; add production redirect URI and JS origin (table above)

##### D. In-app user flow

1. **Sign in** → Login → **Continue with Google** (identity only)  
2. **Settings** → **Connect Google Calendar** (adds calendar scope; pick account + Allow)  
3. **New/edit shift** → syncs to Google Calendar automatically when connected; use **Remove from Google Calendar** to unsync

Email/password still works without Google. Calendar sync requires step 2 for each user who wants events on their calendar.

**Troubleshooting**

| Error | Fix |
|-------|-----|
| `provider is not enabled` | Restart Supabase after editing `supabase/.env` |
| `invalid_client` / OAuth client not found | Client secret missing/wrong in `supabase/.env`, or wrong client type (must be **Web**) |
| Calendar API disabled | Enable Calendar API in GCP (step A1) |
| `access blocked` / app not verified | Use **Testing** mode; add Gmail under **Audience → Test users** (see [docs/google-oauth.md](docs/google-oauth.md)) |
| Sync fails after ~7 days (Testing) | Google expires test-user Calendar tokens; reconnect in Settings |
| Sync fails after weeks (verified) | Reconnect in Settings (access tokens expire; reconnect refreshes) |

### 2. Web app

```bash
cd web
cp .env.example .env.local
# Hosted: set URL + anon key from Supabase Dashboard → Settings → API
# Local:  use http://127.0.0.1:54321 + key from supabase start
npm install
npm run dev
```

Open http://localhost:5173

**WSL + Cursor:** clicking the terminal link may open Cursor's built-in browser on port **5174** instead of 5173. Use **Open in External Browser** (or paste the URL into Chrome/Edge) so you hit the real Vite server.

### 3. Hosted Supabase

Use a cloud project instead of (or alongside) local Docker. Full checklist: **[docs/supabase-hosted.md](docs/supabase-hosted.md)**.

```bash
supabase login
supabase link --project-ref <your-project-ref>   # database password from project create
task supabase:push                               # apply supabase/migrations/
```

Then set `web/.env.local` from **Dashboard → Settings → API**:

```env
VITE_SUPABASE_URL=https://<your-project-ref>.supabase.co
VITE_SUPABASE_ANON_KEY=<publishable-or-anon-key>
```

Connect **GitHub** in the Supabase Dashboard (**Project Settings → Integrations**) to deploy migrations from this repo automatically.

Enable **Google** under **Authentication → Providers** and configure redirect URLs (see [docs/google-oauth.md](docs/google-oauth.md)).

Or sync from `supabase/.env` after credential changes:

```bash
task supabase:auth:google        # hosted (linked project)
task supabase:auth:google:local  # local Docker stack
```

Deploy Edge Functions when ready: `task supabase:functions:deploy`

### 4. Cloudflare Pages

```bash
task web:build
task deploy:pages
```

Or connect the GitHub repo in Cloudflare Pages with build command `cd web && npm run build` and output directory `web/dist`.

Add production and preview URLs to Supabase Auth redirect URLs and Google OAuth authorized origins.

## Environment variables (web)

Public vars only (`VITE_*` in `web/.env.local`):

| Variable | Purpose |
|----------|---------|
| `VITE_SUPABASE_URL` | `https://<ref>.supabase.co` (hosted) or `http://127.0.0.1:54321` (local) |
| `VITE_SUPABASE_ANON_KEY` | Publishable or anon key from Dashboard → Settings → API |
| `VITE_VAPID_PUBLIC_KEY` | Web Push VAPID public key (PR5 push) |

Never put service role keys or VAPID private keys in `VITE_*` vars.

## Postgres schema

| Table | Purpose |
|-------|---------|
| `families` | Family group metadata and invite codes |
| `profiles` | User profiles linked to auth.users and a family |
| `family_members` | Assignable companions |
| `shifts` | Companion shift schedule |
| `unavailabilities` | Companion unavailability blocks |
| `notifications` | In-app notification inbox |
| `family_settings` | Coverage fallback order |
| `push_subscriptions` | Web Push endpoints per user |

RLS policies scope all family data by `profiles.family_id`.

## Commands

```bash
task web:install   # npm install in web/
task web:dev       # Vite dev server
task web:build     # production build → web/dist
task web:test      # Vitest
task web:lint      # ESLint
task web:check     # lint + test + build
task supabase:start
task supabase:linked     # verify hosted link
task supabase:push       # migrations → hosted DB
task supabase:auth:google   # sync Google OAuth to hosted project
task supabase:auth:google:local  # apply Google OAuth to local stack
task supabase:functions:deploy
task deploy:pages        # Cloudflare Pages deploy
```

See `web/AGENTS.md` for client layout and `Taskfile.yml` for all tasks.

## PWA + notifications

1. Open the app in Safari (iPhone) or Chrome
2. **Add to Home Screen** (iPhone: Share → Add to Home Screen)
3. Open from the home screen icon
4. Enable push in Settings

In-app notifications work via Supabase Realtime without push permission. Web Push requires an installed PWA and VAPID keys configured.

## Architecture

```
web/src/
  pages/           # route-level screens
  components/ui/   # reusable UI by domain
  hooks/           # auth, data, mutations
  lib/             # supabase client, schemas, utilities
supabase/
  migrations/      # Postgres schema + RLS
  functions/       # Edge Functions (shift notifications + Web Push)
```
