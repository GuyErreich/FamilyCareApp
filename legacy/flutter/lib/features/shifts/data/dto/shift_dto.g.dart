// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShiftDtoImpl _$$ShiftDtoImplFromJson(
  Map<String, dynamic> json,
) => _$ShiftDtoImpl(
  familyId: json['familyId'] as String,
  assignedUserId: json['assignedUserId'] as String,
  date: const TimestampConverter().fromJson(json['date'] as Object),
  startHour: (json['startHour'] as num).toInt(),
  startMinute: (json['startMinute'] as num).toInt(),
  durationMinutes: (json['durationMinutes'] as num).toInt(),
  endTime: const TimestampConverter().fromJson(json['endTime'] as Object),
  notes: json['notes'] as String?,
  reminderOffsetMinutes:
      (json['reminderOffsetMinutes'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
  calendarEventId: json['calendarEventId'] as String?,
  status: json['status'] as String? ?? 'scheduled',
  repeatRule: json['repeatRule'] as Map<String, dynamic>?,
  createdAt: const TimestampConverter().fromJson(json['createdAt'] as Object),
  updatedAt: const TimestampConverter().fromJson(json['updatedAt'] as Object),
);

Map<String, dynamic> _$$ShiftDtoImplToJson(_$ShiftDtoImpl instance) =>
    <String, dynamic>{
      'familyId': instance.familyId,
      'assignedUserId': instance.assignedUserId,
      'date': const TimestampConverter().toJson(instance.date),
      'startHour': instance.startHour,
      'startMinute': instance.startMinute,
      'durationMinutes': instance.durationMinutes,
      'endTime': const TimestampConverter().toJson(instance.endTime),
      'notes': instance.notes,
      'reminderOffsetMinutes': instance.reminderOffsetMinutes,
      'calendarEventId': instance.calendarEventId,
      'status': instance.status,
      'repeatRule': instance.repeatRule,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
      'updatedAt': const TimestampConverter().toJson(instance.updatedAt),
    };
