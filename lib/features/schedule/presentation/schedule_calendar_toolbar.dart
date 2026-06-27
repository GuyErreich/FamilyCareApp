import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode.dart';
import 'package:flutter/material.dart';

/// Compact navigation row for the calendar screen.
class ScheduleCalendarToolbar extends StatelessWidget {
  const ScheduleCalendarToolbar({
    required this.label,
    required this.viewMode,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onLabelTap,
    required this.onViewModeTap,
    required this.onViewModeLongPress,
    super.key,
  });

  final String label;
  final ScheduleViewMode viewMode;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onLabelTap;
  final VoidCallback onViewModeTap;
  final VoidCallback onViewModeLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 48,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Row(
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
              tooltip: 'Previous',
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: InkWell(
                onTap: onLabelTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                        color: scheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ActionChip(
              label: const Text('Today'),
              onPressed: onToday,
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              labelStyle: Theme.of(context).textTheme.labelSmall,
            ),
            GestureDetector(
              onLongPress: onViewModeLongPress,
              child: IconButton(
                onPressed: onViewModeTap,
                icon: Icon(viewMode.icon),
                tooltip: '${viewMode.tooltip} · tap to cycle, hold for menu',
                visualDensity: VisualDensity.compact,
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
              tooltip: 'Next',
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
