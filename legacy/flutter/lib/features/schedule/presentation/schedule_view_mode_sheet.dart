import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode.dart';
import 'package:flutter/material.dart';

/// Bottom sheet to pick shifts, week, or month overview view.
Future<ScheduleViewMode?> showScheduleViewModeSheet(
  BuildContext context, {
  required ScheduleViewMode current,
}) {
  return showModalBottomSheet<ScheduleViewMode>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Plan view',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              for (final mode in ScheduleViewMode.values)
                ListTile(
                  leading: Icon(mode.icon),
                  title: Text(mode.label),
                  trailing: mode == current
                      ? Icon(
                          Icons.check,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, mode),
                ),
            ],
          ),
        ),
      );
    },
  );
}
