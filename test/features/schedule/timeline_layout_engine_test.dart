import 'package:family_care_scheduler/features/schedule/domain/schedule_timeline_item.dart';
import 'package:family_care_scheduler/features/schedule/domain/timeline_layout_engine.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ShiftTimelineItem _shift({
  required String id,
  required int startHour,
  required int endHour,
}) {
  final date = DateTime(2026, 6, 15);
  return ShiftTimelineItem(
    id: id,
    start: DateTime(2026, 6, 15, startHour),
    end: DateTime(2026, 6, 15, endHour),
    title: 'Companion',
    description: '',
    color: Colors.green,
    textColor: Colors.white,
    shift: Shift(
      id: id,
      familyId: 'f1',
      assignedUserId: 'u1',
      date: date,
      startTime: TimeOfDay(hour: startHour, minute: 0),
      durationMinutes: (endHour - startHour) * 60,
      endTime: DateTime(2026, 6, 15, endHour),
      createdAt: date,
      updatedAt: date,
      status: ShiftStatus.scheduled,
    ),
  );
}

void main() {
  group('TimelineLayoutEngine', () {
    test('places non-overlapping items in column 0', () {
      final placed = TimelineLayoutEngine.layout([
        _shift(id: 'a', startHour: 8, endHour: 10),
        _shift(id: 'b', startHour: 11, endHour: 12),
      ]);

      expect(placed, hasLength(2));
      expect(placed.every((p) => p.columnIndex == 0), isTrue);
      expect(placed.every((p) => p.columnCount == 1), isTrue);
    });

    test('assigns side-by-side columns for overlaps', () {
      final placed = TimelineLayoutEngine.layout([
        _shift(id: 'a', startHour: 9, endHour: 11),
        _shift(id: 'b', startHour: 10, endHour: 12),
      ]);

      final columns = placed.map((p) => p.columnIndex).toSet();
      expect(columns, {0, 1});
      expect(placed.every((p) => p.columnCount == 2), isTrue);
    });

    test('computes top and height in minutes', () {
      final placed = TimelineLayoutEngine.layout([
        _shift(id: 'a', startHour: 9, endHour: 11),
      ]).single;

      expect(placed.topMinutes, 9 * 60);
      expect(placed.heightMinutes, 120);
    });
  });
}
