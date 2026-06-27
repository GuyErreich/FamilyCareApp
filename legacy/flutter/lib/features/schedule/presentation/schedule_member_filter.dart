import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Whether the calendar shows all family members or only the signed-in user.
enum ScheduleMemberFilter {
  all,
  mineOnly,
}

/// Session-only calendar filter (not persisted).
final scheduleMemberFilterProvider =
    StateProvider<ScheduleMemberFilter>((ref) => ScheduleMemberFilter.all);

/// Filters shifts and unavailability for calendar display.
abstract final class ScheduleMemberFilterUtils {
  static List<Shift> filterShifts({
    required List<Shift> shifts,
    required ScheduleMemberFilter filter,
    required String? currentUserId,
  }) {
    if (filter == ScheduleMemberFilter.all || currentUserId == null) {
      return shifts;
    }
    return shifts
        .where((shift) => shift.assignedUserId == currentUserId)
        .toList();
  }

  static List<Unavailability> filterUnavailabilities({
    required List<Unavailability> blocks,
    required ScheduleMemberFilter filter,
    required String? currentUserId,
  }) {
    if (filter == ScheduleMemberFilter.all || currentUserId == null) {
      return blocks;
    }
    return blocks.where((block) => block.userId == currentUserId).toList();
  }
}
