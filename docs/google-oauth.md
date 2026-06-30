# Google OAuth — setup and verification

Reference for Google sign-in and Calendar sync in Family Care Scheduler. GCP project: [family-care-scheduler-dev](https://console.cloud.google.com/?project=family-care-scheduler-dev).

## What the app uses Google for

| Flow | Where in app | Scopes |
|------|----------------|--------|
| Sign in | Login → **Continue with Google** | `email`, `profile`, `openid` (via Supabase) |
| Calendar sync | Settings → **Connect Google Calendar** | `https://www.googleapis.com/auth/calendar` |

Calendar sync stores a `provider_token` in the Supabase session and calls the [Calendar API](https://developers.google.com/calendar/api) from the browser when shifts are saved.

## Google Cloud Console navigation (current UI)

Google moved settings from the old **Edit app** wizard to **Google Auth Platform**:

| Task | Page | Action |
|------|------|--------|
| App name, support email | **Branding** | Edit fields |
| Testing vs Production, test users | **Audience** | Publishing status; **Test users** (Testing only) |
| Add `calendar` scope | **Data Access** | **Add or remove scopes** → search `calendar` → `https://www.googleapis.com/auth/calendar` |
| OAuth client redirect URIs | **Clients** (or APIs & Services → Credentials) | Web client |
| Submit for verification | **Verification center** | After Production + sensitive scopes |

Menu path: **Google Cloud Console** → **Google Auth Platform** (or **APIs & Services** → **OAuth consent screen**).

Help: [Get started with Google Auth Platform](https://support.google.com/cloud/answer/15544987?hl=en), [Manage App Data Access](https://support.google.com/cloud/answer/15549135?hl=en), [Manage App Audience](https://support.google.com/cloud/answer/15549945?hl=en).

## Testing vs Production

| | **Testing** | **Production** (unverified) | **Production** (verified) |
|---|-------------|------------------------------|---------------------------|
| Who can authorize | **Test users** only (up to 100) | Any Google account in theory | Any Google account |
| Test users list | Yes (**Audience**) | No | No |
| Unverified warning | Yes — use **Advanced → Continue** | Often **Access blocked** for Calendar | No (for approved scopes) |
| Sensitive scope `calendar` | Works for test users | Blocked or capped until verified | Works after scope approval |
| Calendar refresh tokens | Expire **7 days** after consent | N/A until verified | Longer-lived after verification |

### Recommendation today (family / private deploy)

Stay in **Testing**:

1. **Audience** → Publishing status: **Testing**
2. **Audience** → **Test users** → add every family Gmail
3. **Data Access** → add `https://www.googleapis.com/auth/calendar`
4. Enable [Google Calendar API](https://console.cloud.google.com/apis/library/calendar-json.googleapis.com?project=family-care-scheduler-dev)

Users connect via Settings → **Connect Google Calendar** and pass the unverified-app screen with **Advanced → Continue**.

If Calendar sync stops after ~7 days in Testing, **Disconnect** → **Connect** again in Settings.

### Why not Production without verification?

Production removes test users and Google treats `calendar` as a **sensitive** scope. Unverified production apps cannot reliably request sensitive scopes — users see **This app hasn't been verified** and often **Access blocked** with no bypass. See [Manage App Audience](https://support.google.com/cloud/answer/15549945?hl=en).

Use Production when you are ready to complete **OAuth app verification** (below).

## OAuth client and Supabase

### Redirect URIs (Web application client)

| Environment | Authorized redirect URI |
|-------------|-------------------------|
| Hosted Supabase | `https://<project-ref>.supabase.co/auth/v1/callback` |
| Local Supabase | `http://127.0.0.1:54321/auth/v1/callback` |

### JavaScript origins

| Environment | Origins |
|-------------|---------|
| Local | `http://localhost:5173`, `http://localhost:5174`, `http://127.0.0.1:5173` |
| Production | `https://<your-pages-domain>` |

### Supabase secrets

Hosted: Dashboard → **Authentication → Providers → Google** (Client ID + Secret).

Local: `supabase/.env` → `SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID`, `SUPABASE_AUTH_EXTERNAL_GOOGLE_SECRET`. Restart: `supabase stop && supabase start`.

Hosted: Dashboard → **Authentication → Providers → Google**; **URL configuration** for Site URL and redirect URLs.

## OAuth app verification (for later — Production)

Complete this when you want **any** family member (or the public) to use Google sign-in and Calendar **without** test users, the unverified warning, or the 7-day Testing token limit.

### When to start

- Moving OAuth consent screen to **Production**
- More than ~100 users, or users you cannot add as test users
- Tired of reconnecting Calendar every week in Testing

### Prerequisites (typical)

Gather before opening **Verification center**:

| Item | Notes |
|------|--------|
| **Privacy policy** | Public HTTPS URL; describes what Google data you collect (email, calendar events for shifts) and how it is used/stored |
| **App homepage** | Public HTTPS URL (e.g. Cloudflare Pages deploy) |
| **Support email** | On consent screen (**Branding**); monitored inbox |
| **Scopes** | Only request what you need: `email`, `profile`, `openid`, `https://www.googleapis.com/auth/calendar` |
| **Demo video** | Required for sensitive/restricted scopes — YouTube link showing end-to-end OAuth and Calendar sync in the app |
| **Domain verification** | Verify domain ownership in Search Console if Google requires it for your homepage |

### Demo video checklist (Calendar scope)

From [Manage App Data Access](https://support.google.com/cloud/answer/15549135?hl=en):

- Show full OAuth flow for each OAuth client in the project (local + production if both exist)
- Consent screen in **English** with the **exact scopes** you request
- Show app functionality that uses Calendar (Settings connect, save shift, event on calendar)
- Show app name and OAuth client ID where relevant

### Submission flow

1. **Data Access** — scopes finalized (`calendar` listed under sensitive scopes)
2. **Audience** → **Publish app** → **Production**
3. **Verification center** → start verification / submit
4. Answer how each scope is used (Calendar: create/update/delete companion shift events on the user's primary calendar)
5. Wait for Google review (days to weeks); respond to any follow-up

Official guide: [Submitting your app for verification](https://support.google.com/cloud/answer/13461325?hl=en).

### After approval

- Remove dependency on test users
- Add new family members without GCP console changes
- Revisit token refresh behavior in app if you later persist `provider_refresh_token` server-side (today the client uses session `provider_token` only)

## Troubleshooting

| Symptom | Likely fix |
|---------|------------|
| `provider is not enabled` | Restart Supabase after `supabase/.env` changes |
| `invalid_client` | Wrong/missing client secret; client type must be **Web** |
| Calendar API errors | Enable Calendar API in GCP |
| No **Test users** section | Publishing status is **Production** — switch to **Testing** |
| `access blocked` / no **Advanced** link | Not a test user, or Production without verification for `calendar` |
| Unverified warning only | Normal in Testing — **Advanced → Continue** |
| Sync stops after ~7 days | Testing mode token expiry — reconnect Calendar in Settings |
| Sync stops after weeks (verified) | Reconnect in Settings; access tokens expire |

## Related project files

- `README.md` — quick setup steps
- `supabase/config.toml` — `[auth.external.google]`
- `web/src/hooks/calendar/useGoogleCalendar.ts` — Calendar OAuth + API calls
- `web/src/lib/constants.ts` — `GOOGLE_CALENDAR_SCOPE`
