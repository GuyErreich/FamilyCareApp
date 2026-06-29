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
# Set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY from supabase start output
npm install
npm run dev
```

Open http://localhost:5173

### 3. Hosted Supabase (production)

1. Create a project at [supabase.com](https://supabase.com)
2. Link and push migrations: `supabase link` then `supabase db push`
3. Enable Auth providers (Email, Google) and add redirect URLs for your Cloudflare Pages domain
4. Set Edge Function secrets (`VAPID_PRIVATE_KEY`, `VAPID_PUBLIC_KEY`) for Web Push
5. Deploy the `on-shift-change` Edge Function

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
| `VITE_SUPABASE_URL` | Supabase project URL |
| `VITE_SUPABASE_ANON_KEY` | Supabase anon key |
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
task deploy:pages  # Cloudflare Pages deploy
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
