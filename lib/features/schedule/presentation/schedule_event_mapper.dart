import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/presentation/shift_event_mapper.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

/// Maps shifts and unavailability blocks to planner [Event]s.
abstract final class ScheduleEventMapper {
  static List<Event> toEvents({
    required List<Shift> shifts,
    required List<Unavailability> unavailabilities,
    required List<FamilyMember> members,
    String? currentUserId,
  }) {
    return [
      ...ShiftEventMapper.toEvents(
        shifts: shifts,
        members: members,
        currentUserId: currentUserId,
      ),
      ...unavailabilities.map((block) {
        final member = _memberFor(block, members);
        final baseColor = _colorFromHex(member?.colorHex ?? '#6B7280');
        final isMine = block.userId == currentUserId;

        return Event(
          startTime: block.startDateTime,
          endTime: block.endDateTime,
          title: member?.name ?? 'Companion',
          description: 'Unavailable · ${DateTimeUtils.formatTimeRange(block.startDateTime, block.endDateTime)}',
          color: isMine
              ? baseColor.withValues(alpha: 0.35)
              : baseColor.withValues(alpha: 0.28),
          textColor: baseColor.withValues(alpha: 0.95),
          data: block,
        );
      }),
    ];
  }

  static void syncController({
    required EventsController controller,
    required List<Event> events,
  }) {
    ShiftEventMapper.syncController(controller: controller, events: events);
  }

  static FamilyMember? _memberFor(
    Unavailability block,
    List<FamilyMember> members,
  ) {
    for (final member in members) {
      if (member.userId == block.userId || member.id == block.userId) {
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
