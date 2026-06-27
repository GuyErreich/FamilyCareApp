import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';

/// Today's schedule grouped for the dashboard.
class TodaySchedule {
  const TodaySchedule({
    required this.current,
    required this.upcoming,
    required this.earlier,
    required this.hasMissingCoverage,
  });

  final Shift? current;
  final List<Shift> upcoming;
  final List<Shift> earlier;
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
    final earlier = <Shift>[];

    for (final shift in active) {
      if (shift.isActive) {
        current = shift;
      } else if (shift.startDateTime.isAfter(now)) {
        upcoming.add(shift);
      } else if (shift.endDateTime.isBefore(now)) {
        earlier.add(shift);
      }
    }

    earlier.sort((a, b) => b.startDateTime.compareTo(a.startDateTime));

    return TodaySchedule(
      current: current,
      upcoming: upcoming,
      earlier: earlier,
      hasMissingCoverage: active.isEmpty,
    );
  }
}
