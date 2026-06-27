import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// Signed-in app user profile stored in Firestore.
@freezed
class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,
    String? displayName,
    String? familyId,
    String? phone,
    @Default('#4A6741') String colorHex,
    String? avatarUrl,
    @Default(<String>[]) List<String> fcmTokens,
    @Default(false) bool googleCalendarConnected,
    @Default(3) int scheduleDaysShowed,
    required DateTime createdAt,
  }) = _AppUser;
}
