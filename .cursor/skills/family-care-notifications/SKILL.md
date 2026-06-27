---
name: family-care-notifications
description: FCM and local notification setup for Family Care Scheduler. Use when configuring push notifications, reminder scheduling, or Android/iOS notification permissions.
---

# Family Care Notifications

## Local reminders

- `LocalNotificationService` schedules from `shift.reminderOffsets`
- Default offsets: 1 day, 1 hour, 15 minutes

## FCM

- Tokens stored on `users.fcmTokens`
- `FcmService.initialize()` on app start
- Cloud Function `onShiftWrite` fans out family notifications

## Platforms

- Request permissions on first launch
- Android channel: `shift_reminders`
