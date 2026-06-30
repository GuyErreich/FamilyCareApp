# Hosted Supabase setup

Connect this repo to a Supabase cloud project and run the web app against it (no local Docker stack required).

Repo: [GuyErreich/FamilyCareApp](https://github.com/GuyErreich/FamilyCareApp)

## 1. Create the Supabase project

1. Open [supabase.com/dashboard](https://supabase.com/dashboard) → **New project**
2. Name it (e.g. `family-care-scheduler`), pick a region, set a **database password** (save it)
3. Wait until the project status is **Active**

Note the **Project URL** and **Project ref** (subdomain), e.g. `https://abcdefghijklmnop.supabase.co` → ref `abcdefghijklmnop`.

## 2. Link this repo (CLI)

From the repository root:

```bash
supabase login
supabase link --project-ref <your-project-ref>
# Enter the database password when prompted
```

Link state is stored in `supabase/.temp/` (gitignored). Each developer links once per machine.

Verify:

```bash
task supabase:linked
```

## 3. Push schema migrations

```bash
task supabase:push
```

This applies everything under `supabase/migrations/` to the hosted database.

Dry run first if you prefer:

```bash
supabase db push --dry-run
```

## 4. Connect GitHub (optional, recommended)

In the Supabase Dashboard for your project:

1. **Project Settings** → **Integrations** → **GitHub**
2. Install the Supabase GitHub app and select **GuyErreich/FamilyCareApp**
3. Enable **Automatic branching** / **Deploy migrations** (wording varies by plan)
4. Set migrations path to `supabase/migrations`

After this, merges to your production branch can deploy migrations without a manual `db push`.

## 5. Configure Authentication

**Authentication → URL configuration**

| Field | Local dev | Production (later) |
|-------|-----------|-------------------|
| Site URL | `http://localhost:5173` | `https://your-app.pages.dev` |
| Redirect URLs | `http://localhost:5173/**`, `http://127.0.0.1:5173/**` | your Pages URL(s) |

**Authentication → Providers**

- **Email** — enabled (default)
- **Google** — enable; paste Client ID + Secret from [Google Cloud](https://console.cloud.google.com/) (see [google-oauth.md](./google-oauth.md))

After editing `supabase/.env`, sync to the hosted project:

```bash
task supabase:auth:google
```

(Local Docker: `task supabase:auth:google:local`)

Add this **Authorized redirect URI** in Google Cloud (Web OAuth client):

```
https://<your-project-ref>.supabase.co/auth/v1/callback
```

Keep `http://localhost:5173` and `http://127.0.0.1:5173` as **JavaScript origins** for local Vite.

## 6. Web app environment

```bash
cd web
cp .env.example .env.local
```

Set from **Project Settings → API** (or `supabase projects api-keys --project-ref <ref>`):

```env
VITE_SUPABASE_URL=https://<your-project-ref>.supabase.co
VITE_SUPABASE_ANON_KEY=<publishable-or-anon-key>
```

Restart the dev server after editing `.env.local`:

```bash
npm run dev
```

Open **http://localhost:5173** in an external browser (not Cursor’s built-in preview on :5174).

## 7. Edge Functions (notifications)

Deploy the shift webhook function:

```bash
task supabase:functions:deploy
```

Set secrets in **Project Settings → Edge Functions → Secrets** (or CLI):

```bash
supabase secrets set VAPID_PUBLIC_KEY=... VAPID_PRIVATE_KEY=... VAPID_SUBJECT=mailto:you@example.com
```

Configure a **Database Webhook** on `public.shifts` pointing to the `on-shift-change` function URL (see `supabase/migrations/20260327120002_shift_notifications.sql`).

## 8. Cloudflare Pages (when ready)

Add the same `VITE_*` vars in Cloudflare Pages → **Settings → Environment variables**, and add your Pages URL to Supabase Auth redirect URLs and Google OAuth origins.

## Quick reference

| Task | Command |
|------|---------|
| Link project | `supabase link --project-ref <ref>` |
| Push migrations | `task supabase:push` |
| Sync Google OAuth | `task supabase:auth:google` (hosted) / `task supabase:auth:google:local` |
| Deploy functions | `task supabase:functions:deploy` |
| Show link status | `task supabase:linked` |
| API keys | Dashboard → Settings → API |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `Cannot find project ref` | Run `supabase link` |
| `db push` password error | Re-run `supabase link` with correct DB password |
| Google `provider is not enabled` | Run `task supabase:auth:google` |
| `config push` storage / `databasePoolMode` error | Known CLI bug — auth still applies; task now treats this as success if Google verifies |
| Google `redirect_uri_mismatch` | Add `https://<ref>.supabase.co/auth/v1/callback` in Google Cloud |
| Auth redirect blocked | Add `http://localhost:5173/**` in Supabase URL configuration |
| RLS / empty data | Sign in and complete onboarding (create/join family) |
