import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:flutter/material.dart';

/// Bottom bar to confirm a timeline slot assignment.
class ScheduleSlotConfirmBar extends StatelessWidget {
  const ScheduleSlotConfirmBar({
    required this.selection,
    required this.onConfirm,
    required this.onClear,
    super.key,
  });

  final ScheduleSlotSelection selection;
  final VoidCallback onConfirm;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 12,
      shadowColor: scheme.shadow.withValues(alpha: 0.2),
      color: scheme.surfaceContainerHigh,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Assign yourself',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '${DateTimeUtils.formatDate(selection.date)} · '
                      '${DateTimeUtils.formatTimeRange(selection.startDateTime, selection.endDateTime)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: onClear, child: const Text('Clear')),
              FilledButton(
                onPressed: onConfirm,
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
