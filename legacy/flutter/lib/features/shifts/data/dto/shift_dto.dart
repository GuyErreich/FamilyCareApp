import 'package:family_care_scheduler/features/auth/data/dto/app_user_dto.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/repeat_rule.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift_dto.freezed.dart';
part 'shift_dto.g.dart';

@freezed
class ShiftDto with _$ShiftDto {
  const factory ShiftDto({
    required String familyId,
    required String assignedUserId,
    @TimestampConverter() required DateTime date,
    required int startHour,
    required int startMinute,
    required int durationMinutes,
    @TimestampConverter() required DateTime endTime,
    String? notes,
    @Default(<int>[]) List<int> reminderOffsetMinutes,
    String? calendarEventId,
    @Default('scheduled') String status,
    Map<String, dynamic>? repeatRule,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _ShiftDto;

  factory ShiftDto.fromJson(Map<String, dynamic> json) =>
      _$ShiftDtoFromJson(json);
}

extension ShiftDtoX on ShiftDto {
  Shift toDomain(String id) => Shift(
        id: id,
        familyId: familyId,
        assignedUserId: assignedUserId,
        date: DateTime(date.year, date.month, date.day),
        startTime: TimeOfDay(hour: startHour, minute: startMinute),
        durationMinutes: durationMinutes,
        endTime: endTime,
        notes: notes,
        reminderOffsets: reminderOffsetMinutes
            .map((m) => Duration(minutes: m))
            .toList(),
        calendarEventId: calendarEventId,
        status: ShiftStatus.values.byName(status),
        repeatRule: repeatRule == null
            ? null
            : RepeatRule(
                frequency: repeatRule!['frequency'] as String,
                interval: repeatRule!['interval'] as int?,
                until: repeatRule!['until'] != null
                    ? DateTime.parse(repeatRule!['until'] as String)
                    : null,
              ),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static ShiftDto fromDomain(Shift shift) => ShiftDto(
        familyId: shift.familyId,
        assignedUserId: shift.assignedUserId,
        date: DateTime(shift.date.year, shift.date.month, shift.date.day),
        startHour: shift.startTime.hour,
        startMinute: shift.startTime.minute,
        durationMinutes: shift.durationMinutes,
        endTime: shift.endTime,
        notes: shift.notes,
        reminderOffsetMinutes:
            shift.reminderOffsets.map((d) => d.inMinutes).toList(),
        calendarEventId: shift.calendarEventId,
        status: shift.status.name,
        repeatRule: shift.repeatRule == null
            ? null
            : {
                'frequency': shift.repeatRule!.frequency,
                'interval': shift.repeatRule!.interval,
                'until': shift.repeatRule!.until?.toIso8601String(),
              },
        createdAt: shift.createdAt,
        updatedAt: shift.updatedAt,
      );
}
