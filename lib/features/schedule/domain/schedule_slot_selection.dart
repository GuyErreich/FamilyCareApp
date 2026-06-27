import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

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

  factory ScheduleSlotSelection.fromSlot(SlotSelection slot) {
    return ScheduleSlotSelection(
      date: DateTimeUtils.dateOnly(slot.startDateTime),
      start: TimeOfDay(
        hour: slot.startDateTime.hour,
        minute: slot.startDateTime.minute,
      ),
      durationMinutes: slot.durationInMinutes,
    );
  }
}
