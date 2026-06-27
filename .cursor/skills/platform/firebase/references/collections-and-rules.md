# Collections & Security Rules

## Access pattern

Every query must filter by the signed-in user's `familyId` from `users/{uid}`. Cross-family reads are forbidden.

## Client vs server

| Concern | Where |
|---|---|
| Shift overlap preview | Client (`SlotOverlapResolver`) — UX hint only |
| Notification fan-out | Cloud Function on `shifts` write |
| Authorization | `firestore.rules` |

Never rely on client-only checks for security.

## Rules change checklist

- [ ] Read `firestore.rules` and `README.md` schema section
- [ ] Confirm `familyId` guard on new paths
- [ ] Deploy rules before shipping client that depends on new paths
- [ ] Consider index requirements for new compound queries (`firestore.indexes.json`)

## Indexes

Add composite indexes when Firestore console or CLI reports missing index links. Commit `firestore.indexes.json` changes with the query that needs them.
