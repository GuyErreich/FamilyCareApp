---
name: family-care-firebase
description: Firebase conventions for Family Care Scheduler. Use when working with Firestore collections, security rules, FCM tokens, or Cloud Functions for shift notifications.
---

# Family Care Firebase

## Collections

- `families`, `users`, `familyMembers`, `shifts`, `notifications`, `settings`

## Rules

- All reads/writes scoped by `users/{uid}.familyId`
- Client overlap checks are UX-only; Cloud Function handles fan-out notifications

## FCM

- Store tokens on `users.fcmTokens`
- `functions/index.js` triggers on `shifts` writes

## Google Calendar API

Enable for OAuth / shift sync (one-time per Firebase project):

1. Open [Google Calendar API](https://console.developers.google.com/apis/api/calendar-json.googleapis.com/overview?project=388117547421) for project `family-care-scheduler-dev` (`388117547421`).
2. Click **Enable**.
3. In **OAuth consent screen**, add scope `https://www.googleapis.com/auth/calendar` if prompted.
4. Wait a few minutes for propagation, then retry in the app.

## Deploy

```bash
npx -y firebase-tools@latest deploy --only firestore:rules,firestore:indexes,functions
```
