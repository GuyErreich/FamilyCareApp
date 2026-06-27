import 'package:family_care_scheduler/features/schedule/presentation/planner_slot_painters.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

/// Shared visual tokens for infinite_calendar_view wrappers.
abstract final class ScheduleCalendarStyle {
  static const _weekdayLabels = [
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
      color: scheme.surfaceContainerLowest,
      border: Border(
        top: BorderSide(
          color: scheme.outlineVariant.withValues(alpha: 0.75),
        ),
      ),
    );
  }

  static const EdgeInsets calendarFramePadding = EdgeInsets.zero;

  static WeekParam monthWeekParam(ColorScheme scheme) {
    return WeekParam(
      startOfWeekDay: 1,
      weekHeight: 132,
      headerHeight: 34,
      daySpacing: 4,
      headerDayText: (dayOfMonth) => _weekdayLabels[(dayOfMonth - 1) % 7],
      headerStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: scheme.onSurface.withValues(alpha: 0.8),
      ),
      headerDayTextColor: (day) {
        final isWeekend = day >= 6;
        return isWeekend
            ? scheme.onSurface.withValues(alpha: 0.55)
            : scheme.onSurface.withValues(alpha: 0.85);
      },
      weekDecoration: const BoxDecoration(),
    );
  }

  static Color monthDayNumberColor(ColorScheme scheme, {required bool isToday}) {
    if (isToday) return scheme.onPrimary;
    return scheme.onSurface.withValues(alpha: 0.82);
  }

  static Color monthDayCellColor(
    ColorScheme scheme, {
    required bool isToday,
    required bool isOutsideMonth,
  }) {
    if (isToday) {
      return Color.alphaBlend(
        scheme.primaryContainer.withValues(alpha: 0.35),
        scheme.surfaceContainerLowest,
      );
    }
    if (isOutsideMonth) {
      return scheme.surfaceContainer.withValues(alpha: 0.45);
    }
    return scheme.surfaceContainerLowest;
  }

  static Border monthDayCellBorder(ColorScheme scheme, {required bool isToday}) {
    return Border.all(
      color: isToday
          ? scheme.primary.withValues(alpha: 0.65)
          : scheme.outlineVariant.withValues(alpha: 0.85),
      width: isToday ? 1.25 : 0.75,
    );
  }

  static Color plannerHourLabelColor(ColorScheme scheme) =>
      scheme.onSurface.withValues(alpha: 0.68);

  static Color plannerHourGridLineColor(ColorScheme scheme) =>
      scheme.outlineVariant.withValues(alpha: 0.72);

  static Color plannerHalfHourGridLineColor(ColorScheme scheme) =>
      scheme.outlineVariant.withValues(alpha: 0.42);

  static Color plannerQuarterHourGridLineColor(ColorScheme scheme) =>
      scheme.outlineVariant.withValues(alpha: 0.22);

  static Color plannerDayColumnDividerColor(ColorScheme scheme) =>
      scheme.outlineVariant.withValues(alpha: 0.8);

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
      scheme.primaryContainer.withValues(alpha: 0.28);

  static Color plannerDayColumnColor(
    ColorScheme scheme, {
    required bool isToday,
  }) {
    if (!isToday) return scheme.surfaceContainerLowest;
    return Color.alphaBlend(
      plannerTodayColumnColor(scheme),
      scheme.surfaceContainerLowest,
    );
  }

  static Color plannerDayHeaderColor(
    ColorScheme scheme, {
    required bool isToday,
  }) {
    if (!isToday) return scheme.surfaceContainerLow;
    return Color.alphaBlend(
      scheme.primaryContainer.withValues(alpha: 0.4),
      scheme.surfaceContainerLow,
    );
  }

  /// Subtle zebra per hour row — not per 15-minute slot or day column.
  static Color plannerHourBandColor(
    ColorScheme scheme,
    int hourIndex, {
    bool isToday = false,
  }) {
    final isAlt = hourIndex.isOdd;
    final base = isAlt
        ? scheme.surfaceContainer.withValues(alpha: 0.35)
        : scheme.surfaceContainerLowest;
    if (!isToday) return base;
    return Color.alphaBlend(plannerTodayColumnColor(scheme), base);
  }
}
