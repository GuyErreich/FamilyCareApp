import 'package:flutter/material.dart';

/// Calendar display modes for the schedule screen.
enum ScheduleViewMode {
  threeDay,
  week,
  month;

  String get label => switch (this) {
        ScheduleViewMode.threeDay => '3-day',
        ScheduleViewMode.week => 'Week',
        ScheduleViewMode.month => 'Month',
      };

  String get tooltip => switch (this) {
        ScheduleViewMode.threeDay => '3-day view',
        ScheduleViewMode.week => 'Week view',
        ScheduleViewMode.month => 'Month view',
      };

  IconData get icon => switch (this) {
        ScheduleViewMode.threeDay => Icons.view_day,
        ScheduleViewMode.week => Icons.view_week,
        ScheduleViewMode.month => Icons.calendar_view_month,
      };

  ScheduleViewMode get next => switch (this) {
        ScheduleViewMode.threeDay => ScheduleViewMode.week,
        ScheduleViewMode.week => ScheduleViewMode.month,
        ScheduleViewMode.month => ScheduleViewMode.threeDay,
      };
}
