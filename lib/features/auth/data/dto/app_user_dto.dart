import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_care_scheduler/features/auth/domain/entities/app_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user_dto.freezed.dart';
part 'app_user_dto.g.dart';

/// Firestore representation of [AppUser].
@freezed
class AppUserDto with _$AppUserDto {
  const factory AppUserDto({
    required String email,
    String? displayName,
    String? familyId,
    String? phone,
    @Default('#4A6741') String colorHex,
    String? avatarUrl,
    @Default(<String>[]) List<String> fcmTokens,
    @Default(false) bool googleCalendarConnected,
    @TimestampConverter() required DateTime createdAt,
  }) = _AppUserDto;

  factory AppUserDto.fromJson(Map<String, dynamic> json) =>
      _$AppUserDtoFromJson(json);
}

extension AppUserDtoX on AppUserDto {
  AppUser toDomain(String id) => AppUser(
        id: id,
        email: email,
        displayName: displayName,
        familyId: familyId,
        phone: phone,
        colorHex: colorHex,
        avatarUrl: avatarUrl,
        fcmTokens: fcmTokens,
        googleCalendarConnected: googleCalendarConnected,
        createdAt: createdAt,
      );

  static AppUserDto fromDomain(AppUser user) => AppUserDto(
        email: user.email,
        displayName: user.displayName,
        familyId: user.familyId,
        phone: user.phone,
        colorHex: user.colorHex,
        avatarUrl: user.avatarUrl,
        fcmTokens: user.fcmTokens,
        googleCalendarConnected: user.googleCalendarConnected,
        createdAt: user.createdAt,
      );
}

/// Converts Firestore [Timestamp] to [DateTime] for json_serializable.
class TimestampConverter implements JsonConverter<DateTime, Object> {
  const TimestampConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is Timestamp) return json.toDate();
    if (json is String) return DateTime.parse(json);
    if (json is int) return DateTime.fromMillisecondsSinceEpoch(json);
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object toJson(DateTime object) => Timestamp.fromDate(object);
}
