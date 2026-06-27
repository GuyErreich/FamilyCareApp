import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Navigates to create shift with timeline slot pre-filled.
void openCreateShiftForSlot(
  BuildContext context, {
  required ScheduleSlotSelection selection,
  required String userId,
}) {
  context.push(
    AppRoutes.createShift,
    extra: {
      'date': selection.date,
      'userId': userId,
      'startHour': selection.start.hour,
      'startMinute': selection.start.minute,
      'durationMinutes': selection.durationMinutes,
    },
  );
}

/// Legend for member colors on the schedule.
class ScheduleLegend extends StatelessWidget {
  const ScheduleLegend({
    required this.members,
    required this.shifts,
    this.currentUserId,
    super.key,
  });

  final List<FamilyMember> members;
  final List<Shift> shifts;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final activeIds = shifts.map((s) => s.assignedUserId).toSet();
    final visible = members
        .where((m) => activeIds.contains(m.userId ?? m.id))
        .toList();

    if (visible.isEmpty) {
      return Text(
        'Tap an open time to assign yourself',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: visible.map((member) {
        final isMe = member.userId == currentUserId;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: _colorFromHex(member.colorHex),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              isMe ? '${member.name} (you)' : member.name,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ],
        );
      }).toList(),
    );
  }
}

Color _colorFromHex(String hex) {
  final value = int.parse(hex.replaceFirst('#', ''), radix: 16);
  return Color(0xFF000000 | value);
}
