import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Saves an app-only unavailability block (no calendar event).
Future<Result<void>> saveUnavailabilityForSlot(
  WidgetRef ref, {
  required ScheduleSlotSelection selection,
  required String userId,
  required String familyId,
}) async {
  final now = DateTime.now();
  final block = Unavailability(
    id: '',
    familyId: familyId,
    userId: userId,
    date: DateTimeUtils.dateOnly(selection.date),
    startTime: selection.start,
    durationMinutes: selection.durationMinutes,
    endTime: selection.endDateTime,
    createdAt: now,
    updatedAt: now,
  );
  final result = await ref.read(unavailabilityRepositoryProvider).create(block);
  return switch (result) {
    Success() => const Success(null),
    Error(:final failure) => Error(failure),
  };
}

/// Bottom sheet to remove an unavailability block.
Future<void> showUnavailabilityActions(
  BuildContext context,
  WidgetRef ref, {
  required Unavailability block,
  required String currentUserId,
  required bool canManageOthers,
}) async {
  final canDelete =
      block.userId == currentUserId || canManageOthers;
  if (!canDelete) return;

  final remove = await showModalBottomSheet<bool>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.event_busy),
            title: Text(
              '${DateTimeUtils.formatDate(block.date)} · '
              '${DateTimeUtils.formatTimeRange(block.startDateTime, block.endDateTime)}',
            ),
            subtitle: const Text('Unavailable'),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
            title: Text(
              'Remove unavailability',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      ),
    ),
  );

  if (remove != true || !context.mounted) return;

  final result = await ref.read(unavailabilityRepositoryProvider).delete(block.id);
  if (!context.mounted) return;

  switch (result) {
    case Success():
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unavailability removed')),
      );
    case Error(:final failure):
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(failure.message)),
      );
  }
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
    final scheme = Theme.of(context).colorScheme;
    final activeIds = shifts.map((s) => s.assignedUserId).toSet();
    final visible = members
        .where((m) => activeIds.contains(m.userId ?? m.id))
        .toList();

    if (visible.isEmpty) {
      return SizedBox(
        height: 32,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Tap an open time to assign yourself',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final member = visible[index];
          final isMe = member.userId == currentUserId;
          final color = _colorFromHex(member.colorHex);
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                isMe ? '${member.name} (you)' : member.name,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Color _colorFromHex(String hex) {
  final value = int.parse(hex.replaceFirst('#', ''), radix: 16);
  return Color(0xFF000000 | value);
}
