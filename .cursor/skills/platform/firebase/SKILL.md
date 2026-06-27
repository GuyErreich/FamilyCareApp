---
name: firebase-platform
description: Firebase and Firestore conventions for Family Care Scheduler — collections, security rules, indexes, Cloud Functions, FCM tokens, and deploy. Use when working with Firestore, firestore.rules, functions/, or Firebase CLI. Extends engineering.
disable-model-invocation: true
---

# Firebase Platform

## Extends

Load `foundations/engineering` first.

## Collections

`families`, `users`, `familyMembers`, `shifts`, `notifications`, `settings` — names in `lib/core/constants/firestore_collections.dart`.

## Security model

- All reads/writes scoped by `users/{uid}.familyId`
- Client overlap checks are **UX-only**; authoritative rules live in `firestore.rules`
- Run security review when changing rules — see `references/collections-and-rules.md`

## Cloud Functions

- `functions/index.js` — `onShiftWrite` fans out family notifications on shift changes
- Deploy with Firebase CLI (see Deploy below)

## FCM

- Tokens on `users.fcmTokens`
- Client: `FcmService.initialize()` in `main.dart`
- See `platform/notifications` skill for local + push wiring

## Google Calendar API

One-time per Firebase project:

1. Enable [Google Calendar API](https://console.developers.google.com/apis/api/calendar-json.googleapis.com/overview?project=388117547421) for `family-care-scheduler-dev`
2. OAuth consent: scope `https://www.googleapis.com/auth/calendar`
3. Wait for propagation before retrying in app

## Deploy

```bash
npx -y firebase-tools@latest deploy --only firestore:rules,firestore:indexes,functions
```

Use `npx -y firebase-tools@latest --version` to verify CLI version.

## When to load references

| Topic | Reference |
|---|---|
| Collection fields, rules checklist | `references/collections-and-rules.md` |
