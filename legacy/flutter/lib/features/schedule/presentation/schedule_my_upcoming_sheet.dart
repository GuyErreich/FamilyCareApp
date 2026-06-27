import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom sheet listing the current user's upcoming shifts.
Future<void> showScheduleMyUpcomingSheet(
  BuildContext context, {
  required List<Shift> shifts,
  required String currentUserId,
}) {
  final now = DateTime.now();
  final horizon = now.add(const Duration(days: 14));

  final upcoming = shifts
      .where((s) => s.status == ShiftStatus.scheduled)
      .where((s) => s.assignedUserId == currentUserId)
      .where((s) => s.endDateTime.isAfter(now) && !s.startDateTime.isAfter(horizon))
      .toList()
    ..sort((a, b) => a.startDateTime.compareTo(b.startDateTime));

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      final scheme = Theme.of(context).colorScheme;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'My upcoming shifts',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Next 14 days',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'No upcoming shifts',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: upcoming.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final shift = upcoming[index];
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(DateTimeUtils.formatDate(shift.date)),
                        subtitle: Text(
                          DateTimeUtils.formatTimeRange(
                            shift.startDateTime,
                            shift.endDateTime,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/shifts/${shift.id}');
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
