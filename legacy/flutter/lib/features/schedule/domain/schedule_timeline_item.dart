import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter/material.dart';

/// A shift or unavailability block rendered on the day/week planner.
sealed class ScheduleTimelineItem {
  const ScheduleTimelineItem({
    required this.id,
    required this.start,
    required this.end,
    required this.title,
    required this.description,
    required this.color,
    required this.textColor,
  });

  final String id;
  final DateTime start;
  final DateTime end;
  final String title;
  final String description;
  final Color color;
  final Color textColor;
}

final class ShiftTimelineItem extends ScheduleTimelineItem {
  const ShiftTimelineItem({
    required super.id,
    required super.start,
    required super.end,
    required super.title,
    required super.description,
    required super.color,
    required super.textColor,
    required this.shift,
  });

  final Shift shift;
}

final class UnavailabilityTimelineItem extends ScheduleTimelineItem {
  const UnavailabilityTimelineItem({
    required super.id,
    required super.start,
    required super.end,
    required super.title,
    required super.description,
    required super.color,
    required super.textColor,
    required this.block,
  });

  final Unavailability block;
}
