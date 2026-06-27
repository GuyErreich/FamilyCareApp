import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/domain/slot_overlap_resolver.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';

/// Conflict messaging when placing or creating a shift.
abstract final class ScheduleShiftConflict {
  static bool hasOverlap({
    required ScheduleSlotSelection selection,
    required List<Shift> shifts,
  }) {
    return SlotOverlapResolver.overlapsShift(
      start: selection.startDateTime,
      durationMinutes: selection.durationMinutes,
      shifts: shifts,
    );
  }

  static String message({
    required ScheduleSlotSelection selection,
    required List<Shift> shifts,
  }) {
    final blocker = SlotOverlapResolver.conflictingShift(
      start: selection.startDateTime,
      durationMinutes: selection.durationMinutes,
      shifts: shifts,
    );
    if (blocker == null) {
      return 'This time overlaps with an existing shift.';
    }
    return 'Overlaps with a shift at '
        '${DateTimeUtils.formatTimeRange(blocker.startDateTime, blocker.endDateTime)}.';
  }
}
