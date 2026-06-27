import 'package:family_care_scheduler/features/schedule/presentation/planner_slot_painters.dart';
import 'package:flutter/material.dart';

/// Layout metrics for the month grid.
class MonthGridMetrics {
  const MonthGridMetrics({
    required this.weekdayLabels,
    required this.daySpacing,
    required this.headerHeight,
    required this.eventHeight,
    required this.eventSpacing,
    required this.spaceBetweenHeaderAndEvents,
    required this.headerStyle,
    required this.headerDayTextColor,
  });

  final List<String> weekdayLabels;
  final double daySpacing;
  final double headerHeight;
  final double eventHeight;
  final double eventSpacing;
  final double spaceBetweenHeaderAndEvents;
  final TextStyle headerStyle;
  final Color Function(int weekdayIndex) headerDayTextColor;
}

/// Shared visual tokens for schedule calendar views.
abstract final class ScheduleCalendarStyle {
  static const weekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  /// Minimal outer chrome — calendar content fills available space.
  static BoxDecoration calendarFrame(ColorScheme scheme) {
    return BoxDecoration(
      color: scheme.surface,
    );
  }

  static const EdgeInsets calendarFramePadding = EdgeInsets.zero;

  static MonthGridMetrics monthGridMetrics(ColorScheme scheme) {
    return MonthGridMetrics(
      weekdayLabels: weekdayLabels,
      daySpacing: 6,
      headerHeight: 24,
      eventHeight: 18,
      eventSpacing: 3,
      spaceBetweenHeaderAndEvents: 4,
      headerStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: scheme.onSurfaceVariant.withValues(alpha: 0.85),
      ),
      headerDayTextColor: (weekdayIndex) {
        final isWeekend = weekdayIndex >= 5;
        return isWeekend
            ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
            : scheme.onSurfaceVariant.withValues(alpha: 0.75);
      },
    );
  }

  static Color monthDayNumberColor(ColorScheme scheme, {required bool isToday}) {
    if (isToday) return scheme.onPrimary;
    return scheme.onSurface.withValues(alpha: 0.88);
  }

  static Color monthDayCellFill(
    ColorScheme scheme, {
    required bool isOutsideMonth,
  }) {
    if (isOutsideMonth) {
      return scheme.surfaceContainerLowest.withValues(alpha: 0.45);
    }
    return scheme.surfaceContainerLowest;
  }

  static BoxDecoration monthDayCellBoxDecoration(
    ColorScheme scheme, {
    required bool isToday,
    required bool isOutsideMonth,
  }) {
    return BoxDecoration(
      color: monthDayCellFill(scheme, isOutsideMonth: isOutsideMonth),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: isToday
            ? scheme.primary
            : scheme.outlineVariant.withValues(alpha: 0.45),
        width: isToday ? 2 : 0.5,
      ),
    );
  }

  static BoxDecoration? monthDayNumberDecoration(
    ColorScheme scheme, {
    required bool isToday,
  }) {
    if (!isToday) return null;
    return BoxDecoration(
      color: scheme.primaryContainer.withValues(alpha: 0.55),
      shape: BoxShape.circle,
    );
  }

  static Color plannerHourLabelColor(ColorScheme scheme) =>
      scheme.onSurface.withValues(alpha: 0.55);

  static Color plannerHourGridLineColor(ColorScheme scheme) =>
      scheme.outlineVariant.withValues(alpha: 0.45);

  static Color plannerHalfHourGridLineColor(ColorScheme scheme) =>
      scheme.outlineVariant.withValues(alpha: 0.28);

  static Color plannerQuarterHourGridLineColor(ColorScheme scheme) =>
      scheme.outlineVariant.withValues(alpha: 0.14);

  static Color plannerDayColumnDividerColor(ColorScheme scheme) =>
      scheme.outlineVariant.withValues(alpha: 0.55);

  static PlannerSlotGridPainter plannerGridPainter({
    required double heightPerMinute,
    required ColorScheme scheme,
  }) {
    return PlannerSlotGridPainter(
      scheme: scheme,
      heightPerMinute: heightPerMinute,
    );
  }

  static Color plannerTodayColumnColor(ColorScheme scheme) =>
      scheme.primaryContainer.withValues(alpha: 0.22);

  static Color plannerDayColumnColor(
    ColorScheme scheme, {
    required bool isToday,
  }) {
    if (!isToday) return scheme.surface;
    return Color.alphaBlend(
      plannerTodayColumnColor(scheme),
      scheme.surface,
    );
  }

  static Color plannerDayHeaderColor(
    ColorScheme scheme, {
    required bool isToday,
  }) {
    if (!isToday) return Colors.transparent;
    return scheme.primaryContainer.withValues(alpha: 0.25);
  }

  /// Subtle zebra per hour row — not per 15-minute slot or day column.
  static Color plannerHourBandColor(
    ColorScheme scheme,
    int hourIndex, {
    bool isToday = false,
  }) {
    final isAlt = hourIndex.isOdd;
    final base = isAlt
        ? scheme.surfaceContainer.withValues(alpha: 0.2)
        : scheme.surface;
    if (!isToday) return base;
    return Color.alphaBlend(plannerTodayColumnColor(scheme), base);
  }
}
