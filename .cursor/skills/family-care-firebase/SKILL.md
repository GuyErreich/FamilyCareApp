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

## Deploy

```bash
npx -y firebase-tools@latest deploy --only firestore:rules,firestore:indexes,functions
```
