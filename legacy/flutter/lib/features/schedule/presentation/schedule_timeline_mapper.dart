import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_timeline_item.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter/material.dart';

/// Maps domain shifts and unavailability to planner timeline items.
abstract final class ScheduleTimelineMapper {
  static List<ScheduleTimelineItem> toItems({
    required List<Shift> shifts,
    required List<Unavailability> unavailabilities,
    required List<FamilyMember> members,
    String? currentUserId,
  }) {
    return [
      ..._shiftItems(
        shifts: shifts,
        members: members,
        currentUserId: currentUserId,
      ),
      ..._unavailabilityItems(
        blocks: unavailabilities,
        members: members,
        currentUserId: currentUserId,
      ),
    ];
  }

  static List<ScheduleTimelineItem> itemsForDay({
    required List<ScheduleTimelineItem> items,
    required DateTime day,
  }) {
    final dayOnly = DateTimeUtils.dateOnly(day);
    return items.where((item) {
      final itemDay = DateTimeUtils.dateOnly(item.start);
      return itemDay == dayOnly;
    }).toList();
  }

  static List<ScheduleTimelineItem> _shiftItems({
    required List<Shift> shifts,
    required List<FamilyMember> members,
    String? currentUserId,
  }) {
    return shifts
        .where((shift) => shift.status == ShiftStatus.scheduled)
        .map((shift) {
          final member = _memberForShift(shift, members);
          final color = _colorFromHex(member?.colorHex ?? '#4A6741');
          final isMine = shift.assignedUserId == currentUserId;

          return ShiftTimelineItem(
            id: shift.id,
            start: shift.startDateTime,
            end: shift.endDateTime,
            title: member?.name ?? 'Companion',
            description: DateTimeUtils.formatTimeRange(
              shift.startDateTime,
              shift.endDateTime,
            ),
            color: isMine ? color : color.withValues(alpha: 0.88),
            textColor: Colors.white,
            shift: shift,
          );
        })
        .toList();
  }

  static List<ScheduleTimelineItem> _unavailabilityItems({
    required List<Unavailability> blocks,
    required List<FamilyMember> members,
    String? currentUserId,
  }) {
    return blocks.map((block) {
      final member = _memberForUser(block.userId, members);
      final baseColor = _colorFromHex(member?.colorHex ?? '#6B7280');
      final isMine = block.userId == currentUserId;

      return UnavailabilityTimelineItem(
        id: block.id,
        start: block.startDateTime,
        end: block.endDateTime,
        title: member?.name ?? 'Companion',
        description:
            'Unavailable · ${DateTimeUtils.formatTimeRange(block.startDateTime, block.endDateTime)}',
        color: isMine
            ? baseColor.withValues(alpha: 0.35)
            : baseColor.withValues(alpha: 0.28),
        textColor: baseColor.withValues(alpha: 0.95),
        block: block,
      );
    }).toList();
  }

  static FamilyMember? _memberForShift(
    Shift shift,
    List<FamilyMember> members,
  ) {
    for (final member in members) {
      if (member.userId == shift.assignedUserId ||
          member.id == shift.assignedUserId) {
        return member;
      }
    }
    return null;
  }

  static FamilyMember? _memberForUser(
    String userId,
    List<FamilyMember> members,
  ) {
    for (final member in members) {
      if (member.userId == userId || member.id == userId) {
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
