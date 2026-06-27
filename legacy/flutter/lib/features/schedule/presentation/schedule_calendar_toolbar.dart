import 'package:flutter/material.dart';

/// Date navigation and actions for the Plan tab.
class ScheduleCalendarToolbar extends StatelessWidget {
  const ScheduleCalendarToolbar({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
    required this.onLabelTap,
    this.mineFilterActive = false,
    this.onMineFilterTap,
    this.onUpcomingTap,
    this.onQuickAddTap,
    super.key,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;
  final VoidCallback onLabelTap;
  final bool mineFilterActive;
  final VoidCallback? onMineFilterTap;
  final VoidCallback? onUpcomingTap;
  final VoidCallback? onQuickAddTap;

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
            if (onMineFilterTap != null)
              IconButton(
                onPressed: onMineFilterTap,
                icon: Icon(
                  mineFilterActive ? Icons.person : Icons.people_outline,
                ),
                tooltip: 'Show only my schedule',
                visualDensity: VisualDensity.compact,
                color: mineFilterActive ? scheme.primary : null,
              ),
            Expanded(
              child: InkWell(
                onTap: onLabelTap,
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
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
            if (onUpcomingTap != null)
              IconButton(
                onPressed: onUpcomingTap,
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'My upcoming shifts',
                visualDensity: VisualDensity.compact,
              ),
            if (onQuickAddTap != null)
              IconButton(
                onPressed: onQuickAddTap,
                icon: const Icon(Icons.add),
                tooltip: 'Add shift',
                visualDensity: VisualDensity.compact,
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
