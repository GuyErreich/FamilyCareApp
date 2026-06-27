import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Day | Week | Calendar picker for the Plan tab.
class SchedulePlanModeBar extends StatelessWidget {
  const SchedulePlanModeBar({
    required this.mode,
    required this.onModeChanged,
    super.key,
  });

  final ScheduleViewMode mode;
  final ValueChanged<ScheduleViewMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: SegmentedButton<ScheduleViewMode>(
        segments: [
          for (final m in ScheduleViewMode.values)
            ButtonSegment(
              value: m,
              label: Text(m.label),
              icon: Icon(m.icon, size: 18),
            ),
        ],
        selected: {mode},
        onSelectionChanged: (values) {
          HapticFeedback.selectionClick();
          onModeChanged(values.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
