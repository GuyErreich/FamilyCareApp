import 'package:family_care_scheduler/features/schedule/domain/planner_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleSlotSelection', () {
    test('fromDateTimeRange builds date and time', () {
      final start = DateTime(2026, 6, 15, 14, 30);
      final selection = ScheduleSlotSelection.fromDateTimeRange(start, 120);

      expect(selection.date, DateTime(2026, 6, 15));
      expect(selection.start, const TimeOfDay(hour: 14, minute: 30));
      expect(selection.durationMinutes, 120);
      expect(selection.endDateTime, DateTime(2026, 6, 15, 16, 30));
    });

    test('fromPlannerSlot mirrors planner selection', () {
      final planner = PlannerSlotSelection(
        columnIndex: 1,
        initialStartDateTime: DateTime(2026, 6, 15, 9),
        startDateTime: DateTime(2026, 6, 15, 10),
        durationInMinutes: 90,
      );

      final selection = ScheduleSlotSelection.fromPlannerSlot(planner);

      expect(selection.startDateTime, planner.startDateTime);
      expect(selection.durationMinutes, 90);
    });
  });
}
