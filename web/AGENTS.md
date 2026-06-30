# Family Care Web App

Greenfield Vite + React + TypeScript PWA. Backend: Supabase. Deploy: Cloudflare Pages.

## Skills (load order)

1. `~/.cursor/skills/code/foundations/engineering`
2. `~/.cursor/skills/code/languages/nodejs`
3. `~/.cursor/skills/code/web/libs/react` + `code/web/ui`
4. `~/.cursor/skills/project/platform/supabase`
5. `project/ux` + `project/schedule` for planner UX bar

## Commands

```bash
npm install
npm run dev       # http://localhost:5173
npm run build
npm run lint
npm run test
```

## Environment

Copy `.env.example` to `.env.local`:

- `VITE_SUPABASE_URL` — hosted: `https://<ref>.supabase.co`; local: `http://127.0.0.1:54321`
- `VITE_SUPABASE_ANON_KEY` — from Dashboard → Settings → API (hosted) or `supabase start` (local)
- `VITE_VAPID_PUBLIC_KEY` (optional, for Web Push)

Hosted setup: [docs/supabase-hosted.md](../docs/supabase-hosted.md).

## Layout

```
src/
  pages/                 # route entry points
  components/ui/         # reusable UI by domain
  hooks/                 # auth, family, shifts, notifications
  lib/                   # supabase client, types, dates
  styles/
```

See `src/components/ui/AGENT.md`, `src/hooks/AGENT.md`, `src/lib/AGENT.md`.
