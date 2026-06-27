import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/planner_slot_selection.dart';
import 'package:flutter/material.dart';

/// A proposed companion slot on the schedule.
class ScheduleSlotSelection {
  const ScheduleSlotSelection({
    required this.date,
    required this.start,
    required this.durationMinutes,
  });

  final DateTime date;
  final TimeOfDay start;
  final int durationMinutes;

  DateTime get startDateTime => DateTimeUtils.combineDateAndTime(date, start);

  DateTime get endDateTime =>
      startDateTime.add(Duration(minutes: durationMinutes));

  factory ScheduleSlotSelection.fromDateTimeRange(
    DateTime start,
    int durationMinutes,
  ) {
    return ScheduleSlotSelection(
      date: DateTimeUtils.dateOnly(start),
      start: TimeOfDay(hour: start.hour, minute: start.minute),
      durationMinutes: durationMinutes,
    );
  }

  factory ScheduleSlotSelection.fromPlannerSlot(PlannerSlotSelection slot) {
    return ScheduleSlotSelection.fromDateTimeRange(
      slot.startDateTime,
      slot.durationInMinutes,
    );
  }
}
