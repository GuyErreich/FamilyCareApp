import 'package:family_care_scheduler/core/utils/date_time_utils.dart';

/// Flags calendar days within a range that have no scheduled shifts.
class DetectMissingShiftsUseCase {
  const DetectMissingShiftsUseCase();

  Set<DateTime> call({
    required DateTime start,
    required DateTime end,
    required Set<DateTime> daysWithShifts,
  }) {
    final missing = <DateTime>{};
    var cursor = DateTimeUtils.dateOnly(start);
    final last = DateTimeUtils.dateOnly(end);

    while (!cursor.isAfter(last)) {
      if (!daysWithShifts.contains(cursor)) {
        missing.add(cursor);
      }
      cursor = cursor.add(const Duration(days: 1));
    }
    return missing;
  }
}
