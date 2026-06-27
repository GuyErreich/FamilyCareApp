---
name: notifications-platform
description: FCM and local notification setup for Family Care Scheduler — permissions, channels, reminder scheduling, and Cloud Function fan-out. Use when configuring push notifications, reminder scheduling, or Android/iOS notification permissions. Extends firebase-platform.
disable-model-invocation: true
---

# Notifications Platform

## Extends

Load `foundations/engineering` and `platform/firebase` first.

## Local reminders

- `LocalNotificationService` schedules from `shift.reminderOffsets`
- Default offsets: 1 day, 1 hour, 15 minutes
- Initialize in `main.dart` before `runApp`

## FCM

- Tokens stored on `users.fcmTokens`
- `FcmService.initialize()` on app start
- Cloud Function `onShiftWrite` fans out family notifications

## Platforms

- Request permissions on first launch
- Android channel: `shift_reminders`

## Skill pairing

Firestore shift writes → function fan-out → FCM. Local reminders are client-scheduled from shift data; keep both paths in mind when changing shift lifecycle.
