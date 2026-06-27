import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';

/// Today's schedule grouped for the dashboard.
class TodaySchedule {
  const TodaySchedule({
    required this.current,
    required this.upcoming,
    required this.hasMissingCoverage,
  });

  final Shift? current;
  final List<Shift> upcoming;
  final bool hasMissingCoverage;
}

/// Builds the dashboard view model for today's shifts.
class GetTodayScheduleUseCase {
  const GetTodayScheduleUseCase();

  TodaySchedule call(List<Shift> shifts) {
    final now = DateTime.now();
    final active = shifts.where((s) => s.status == ShiftStatus.scheduled).toList()
      ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

    Shift? current;
    final upcoming = <Shift>[];

    for (final shift in active) {
      if (shift.isActive) {
        current = shift;
      } else if (shift.startDateTime.isAfter(now)) {
        upcoming.add(shift);
      }
    }

    return TodaySchedule(
      current: current,
      upcoming: upcoming,
      hasMissingCoverage: active.isEmpty,
    );
  }
}

// Re-export ShiftStatus for convenience in this file's consumers
export 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
