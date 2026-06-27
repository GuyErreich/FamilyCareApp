import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';

/// Result of placing a proposed slot on the timeline.
class SlotPlacementResult {
  const SlotPlacementResult({
    required this.start,
    required this.durationMinutes,
    required this.hasConflict,
  });

  final DateTime start;
  final int durationMinutes;
  final bool hasConflict;
}

/// Resolves slot placement against existing scheduled shifts.
abstract final class SlotOverlapResolver {
  static bool overlapsShift({
    required DateTime start,
    required int durationMinutes,
    required List<Shift> shifts,
  }) {
    final end = start.add(Duration(minutes: durationMinutes));
    for (final shift in shifts) {
      if (shift.status != ShiftStatus.scheduled) continue;
      if (!_sameDay(shift.date, start)) continue;
      if (start.isBefore(shift.endDateTime) && end.isAfter(shift.startDateTime)) {
        return true;
      }
    }
    return false;
  }

  /// Free placement while dragging: clamp to the day grid only, flag conflicts.
  static SlotPlacementResult resolveFree({
    required DateTime proposedStart,
    required int durationMinutes,
    required List<Shift> shifts,
  }) {
    final clamped = _clampStart(proposedStart, durationMinutes);
    return SlotPlacementResult(
      start: clamped,
      durationMinutes: durationMinutes,
      hasConflict: overlapsShift(
        start: clamped,
        durationMinutes: durationMinutes,
        shifts: shifts,
      ),
    );
  }

  /// Free resize while dragging: clamp duration only, flag conflicts.
  static SlotPlacementResult resolveDurationFree({
    required DateTime start,
    required int proposedDurationMinutes,
    required List<Shift> shifts,
  }) {
    const snap = ScheduleConstants.snapMinutes;
    final startMinutes = start.hour * 60 + start.minute;
    final maxDuration = ScheduleConstants.minutesPerDay - startMinutes;
    final duration = proposedDurationMinutes.clamp(snap, maxDuration);

    return SlotPlacementResult(
      start: start,
      durationMinutes: duration,
      hasConflict: overlapsShift(
        start: start,
        durationMinutes: duration,
        shifts: shifts,
      ),
    );
  }

  /// Keeps [proposedStart] when free; otherwise snaps above the blocking shift.
  static SlotPlacementResult resolve({
    required DateTime proposedStart,
    required int durationMinutes,
    required List<Shift> shifts,
  }) {
    final clamped = _clampStart(proposedStart, durationMinutes);
    if (!overlapsShift(
      start: clamped,
      durationMinutes: durationMinutes,
      shifts: shifts,
    )) {
      return SlotPlacementResult(
        start: clamped,
        durationMinutes: durationMinutes,
        hasConflict: false,
      );
    }

    var snapped = clamped;
    for (var i = 0; i < 12; i++) {
      final blocker = _firstOverlapping(snapped, durationMinutes, shifts);
      if (blocker == null) break;
      snapped = _clampStart(
        blocker.startDateTime.subtract(Duration(minutes: durationMinutes)),
        durationMinutes,
      );
    }

    return SlotPlacementResult(
      start: snapped,
      durationMinutes: durationMinutes,
      hasConflict: true,
    );
  }

  /// Caps [proposedDurationMinutes] so the slot end stays above taken time.
  static SlotPlacementResult resolveDuration({
    required DateTime start,
    required int proposedDurationMinutes,
    required List<Shift> shifts,
  }) {
    const snap = ScheduleConstants.snapMinutes;
    final startMinutes = start.hour * 60 + start.minute;
    final maxDuration = ScheduleConstants.minutesPerDay - startMinutes;
    var duration = proposedDurationMinutes.clamp(snap, maxDuration);

    if (!overlapsShift(start: start, durationMinutes: duration, shifts: shifts)) {
      return SlotPlacementResult(
        start: start,
        durationMinutes: duration,
        hasConflict: false,
      );
    }

    final blocker = _firstOverlapping(start, duration, shifts);
    if (blocker == null) {
      return SlotPlacementResult(
        start: start,
        durationMinutes: duration,
        hasConflict: false,
      );
    }

    final capped = snap *
        (blocker.startDateTime.difference(start).inMinutes / snap).floor();
    final snappedDuration = capped.clamp(snap, duration);

    return SlotPlacementResult(
      start: start,
      durationMinutes: snappedDuration,
      hasConflict: true,
    );
  }

  static Shift? conflictingShift({
    required DateTime start,
    required int durationMinutes,
    required List<Shift> shifts,
  }) =>
      _firstOverlapping(start, durationMinutes, shifts);

  static Shift? _firstOverlapping(
    DateTime start,
    int durationMinutes,
    List<Shift> shifts,
  ) {
    final end = start.add(Duration(minutes: durationMinutes));
    Shift? earliest;
    for (final shift in shifts) {
      if (shift.status != ShiftStatus.scheduled) continue;
      if (!_sameDay(shift.date, start)) continue;
      if (start.isBefore(shift.endDateTime) && end.isAfter(shift.startDateTime)) {
        if (earliest == null ||
            shift.startDateTime.isBefore(earliest.startDateTime)) {
          earliest = shift;
        }
      }
    }
    return earliest;
  }

  static DateTime _clampStart(DateTime start, int durationMinutes) {
    final day = DateTimeUtils.dateOnly(start);
    final maxStartMinutes = ScheduleConstants.minutesPerDay - durationMinutes;
    final minutes =
        (start.hour * 60 + start.minute).clamp(0, maxStartMinutes);
    return day.add(Duration(minutes: minutes));
  }

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
