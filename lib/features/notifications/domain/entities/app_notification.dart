import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';

/// Types of in-app and push notifications.
enum NotificationType {
  shiftCreated,
  shiftUpdated,
  shiftCancelled,
  shiftNeedsCoverage,
  companionChanged,
  reminder,
}

/// A notification record for a user.
@freezed
class AppNotification with _$AppNotification {
  const factory AppNotification({
    required String id,
    required String familyId,
    required String userId,
    required NotificationType type,
    String? shiftId,
    required String title,
    required String body,
    @Default(false) bool read,
    required DateTime createdAt,
  }) = _AppNotification;
}
