import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';

/// Utilities for shift interval overlap detection.
abstract final class ShiftOverlapUtils {
  /// Returns true when [candidate] overlaps any shift in [existing].
  static bool hasOverlap(Shift candidate, List<Shift> existing) {
    final candidateStart = candidate.startDateTime;
    final candidateEnd = candidate.endDateTime;

    for (final shift in existing) {
      if (shift.id == candidate.id) continue;
      if (!_sameDay(shift.date, candidate.date)) continue;

      final start = shift.startDateTime;
      final end = shift.endDateTime;
      if (candidateStart.isBefore(end) && candidateEnd.isAfter(start)) {
        return true;
      }
    }
    return false;
  }

  /// Returns true when the same user is double-booked.
  static bool hasDoubleBooking(Shift candidate, List<Shift> existing) {
    return existing.any((shift) {
      if (shift.id == candidate.id) return false;
      if (shift.assignedUserId != candidate.assignedUserId) return false;
      if (!_sameDay(shift.date, candidate.date)) return false;
      return candidate.startDateTime.isBefore(shift.endDateTime) &&
          candidate.endDateTime.isAfter(shift.startDateTime);
    });
  }

  static bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
