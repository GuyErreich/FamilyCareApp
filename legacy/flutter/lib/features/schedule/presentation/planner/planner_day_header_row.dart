import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_style.dart';
import 'package:flutter/material.dart';

/// Fixed day-of-week header above planner columns.
class PlannerDayHeaderRow extends StatelessWidget {
  const PlannerDayHeaderRow({
    required this.days,
    required this.timeGutterWidth,
    super.key,
  });

  final List<DateTime> days;
  final double timeGutterWidth;

  static const _labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: scheme.surfaceContainerLow,
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            SizedBox(width: timeGutterWidth),
            for (final day in days)
              Expanded(
                child: _DayHeader(day: day),
              ),
          ],
        ),
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isToday = DateUtils.isSameDay(day, DateTime.now());

    return DecoratedBox(
      decoration: BoxDecoration(
        color: ScheduleCalendarStyle.plannerDayHeaderColor(
          scheme,
          isToday: isToday,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            PlannerDayHeaderRow._labels[day.weekday - 1],
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: isToday
                      ? scheme.primary
                      : scheme.onSurfaceVariant.withValues(alpha: 0.75),
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: isToday
                ? BoxDecoration(
                    color: scheme.primary,
                    shape: BoxShape.circle,
                  )
                : null,
            child: Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isToday ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
