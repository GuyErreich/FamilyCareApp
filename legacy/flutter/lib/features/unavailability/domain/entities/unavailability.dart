import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'unavailability.freezed.dart';

/// App-only block when a companion cannot cover a time range.
@freezed
class Unavailability with _$Unavailability {
  const Unavailability._();

  const factory Unavailability({
    required String id,
    required String familyId,
    required String userId,
    required DateTime date,
    required TimeOfDay startTime,
    required int durationMinutes,
    required DateTime endTime,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Unavailability;

  DateTime get startDateTime =>
      DateTimeUtils.combineDateAndTime(date, startTime);

  DateTime get endDateTime => endTime;
}
