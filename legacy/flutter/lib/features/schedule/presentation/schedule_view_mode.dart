import 'package:flutter/material.dart';

/// Plan tab display modes: single-day timeline, week planner, or month grid.
enum ScheduleViewMode {
  day,
  week,
  calendar;

  String get label => switch (this) {
        ScheduleViewMode.day => 'Day',
        ScheduleViewMode.week => 'Week',
        ScheduleViewMode.calendar => 'Calendar',
      };

  String get tooltip => switch (this) {
        ScheduleViewMode.day => 'Day timeline',
        ScheduleViewMode.week => 'Week timeline',
        ScheduleViewMode.calendar => 'Month calendar',
      };

  IconData get icon => switch (this) {
        ScheduleViewMode.day => Icons.view_timeline,
        ScheduleViewMode.week => Icons.view_week,
        ScheduleViewMode.calendar => Icons.calendar_view_month,
      };

  /// Planner column count when not in calendar mode.
  int get plannerDays => switch (this) {
        ScheduleViewMode.day => 1,
        ScheduleViewMode.week => 7,
        ScheduleViewMode.calendar => 1,
      };

  bool get isMonthGrid => this == ScheduleViewMode.calendar;
}
