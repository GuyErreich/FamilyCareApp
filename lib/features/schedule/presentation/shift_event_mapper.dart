import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

/// Maps domain [Shift]s to calendar [Event]s for infinite_calendar_view.
abstract final class ShiftEventMapper {
  static List<Event> toEvents({
    required List<Shift> shifts,
    required List<FamilyMember> members,
    String? currentUserId,
  }) {
    return shifts
        .where((shift) => shift.status == ShiftStatus.scheduled)
        .map((shift) {
          final member = _memberFor(shift, members);
          final color = _colorFromHex(member?.colorHex ?? '#4A6741');
          final isMine = shift.assignedUserId == currentUserId;

          return Event(
            startTime: shift.startDateTime,
            endTime: shift.endDateTime,
            title: member?.name ?? 'Companion',
            description: DateTimeUtils.formatTimeRange(
              shift.startDateTime,
              shift.endDateTime,
            ),
            color: isMine ? color : color.withValues(alpha: 0.88),
            textColor: Colors.white,
            data: shift,
          );
        })
        .toList();
  }

  static void syncController({
    required EventsController controller,
    required List<Event> events,
  }) {
    controller.updateCalendarData((calendarData) {
      calendarData.clearAll();
      calendarData.addEvents(events);
    });
  }

  static FamilyMember? _memberFor(Shift shift, List<FamilyMember> members) {
    for (final member in members) {
      if (member.userId == shift.assignedUserId ||
          member.id == shift.assignedUserId) {
        return member;
      }
    }
    return null;
  }

  static Color _colorFromHex(String hex) {
    final value = int.parse(hex.replaceFirst('#', ''), radix: 16);
    return Color(0xFF000000 | value);
  }
}
