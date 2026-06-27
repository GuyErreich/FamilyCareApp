import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/repeat_rule.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift.freezed.dart';

/// A scheduled companion shift for Grandpa.
@freezed
class Shift with _$Shift {
  const Shift._();

  const factory Shift({
    required String id,
    required String familyId,
    required String assignedUserId,
    required DateTime date,
    required TimeOfDay startTime,
    required int durationMinutes,
    required DateTime endTime,
    String? notes,
    @Default(<Duration>[]) List<Duration> reminderOffsets,
    String? calendarEventId,
    @Default(ShiftStatus.scheduled) ShiftStatus status,
    RepeatRule? repeatRule,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Shift;

  DateTime get startDateTime =>
      DateTimeUtils.combineDateAndTime(date, startTime);

  DateTime get endDateTime => endTime;

  bool get isInPast => endDateTime.isBefore(DateTime.now());

  bool get isActive {
    final now = DateTime.now();
    return status == ShiftStatus.scheduled &&
        !now.isBefore(startDateTime) &&
        now.isBefore(endDateTime);
  }
}
