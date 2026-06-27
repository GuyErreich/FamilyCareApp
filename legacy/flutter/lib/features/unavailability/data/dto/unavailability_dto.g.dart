// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unavailability_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UnavailabilityDtoImpl _$$UnavailabilityDtoImplFromJson(
  Map<String, dynamic> json,
) => _$UnavailabilityDtoImpl(
  familyId: json['familyId'] as String,
  userId: json['userId'] as String,
  date: const TimestampConverter().fromJson(json['date'] as Object),
  startHour: (json['startHour'] as num).toInt(),
  startMinute: (json['startMinute'] as num).toInt(),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  endTime: const TimestampConverter().fromJson(json['endTime'] as Object),
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
);

Map<String, dynamic> _$$UnavailabilityDtoImplToJson(
  _$UnavailabilityDtoImpl instance,
) => <String, dynamic>{
  'familyId': instance.familyId,
  'userId': instance.userId,
  'date': const TimestampConverter().toJson(instance.date),
  'startHour': instance.startHour,
  'startMinute': instance.startMinute,
  'durationMinutes': instance.durationMinutes,
  'endTime': const TimestampConverter().toJson(instance.endTime),
  'createdAt': const TimestampConverter().toJson(instance.createdAt),
  'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
};
