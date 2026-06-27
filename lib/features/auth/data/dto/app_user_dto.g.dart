// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppUserDtoImpl _$$AppUserDtoImplFromJson(
  Map<String, dynamic> json,
) => _$AppUserDtoImpl(
  email: json['email'] as String,
  displayName: json['displayName'] as String?,
  familyId: json['familyId'] as String?,
  phone: json['phone'] as String?,
  colorHex: json['colorHex'] as String? ?? '#4A6741',
  avatarUrl: json['avatarUrl'] as String?,
  fcmTokens:
      (json['fcmTokens'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  googleCalendarConnected: json['googleCalendarConnected'] as bool? ?? false,
  scheduleDaysShowed: (json['scheduleDaysShowed'] as num?)?.toInt() ?? 3,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
);

Map<String, dynamic> _$$AppUserDtoImplToJson(_$AppUserDtoImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'displayName': instance.displayName,
      'familyId': instance.familyId,
      'phone': instance.phone,
      'colorHex': instance.colorHex,
      'avatarUrl': instance.avatarUrl,
      'fcmTokens': instance.fcmTokens,
      'googleCalendarConnected': instance.googleCalendarConnected,
      'scheduleDaysShowed': instance.scheduleDaysShowed,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };
