import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/material.dart';

/// Chip data for a shift on the month grid.
class MonthShiftChipData {
  const MonthShiftChipData({
    required this.shift,
    required this.title,
    required this.color,
  });

  final Shift shift;
  final String title;
  final Color color;
}
