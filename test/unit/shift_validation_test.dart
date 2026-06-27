import 'package:family_care_scheduler/core/utils/invite_code_generator.dart';
import 'package:family_care_scheduler/core/utils/shift_overlap_utils.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InviteCodeGenerator', () {
    test('generates code of expected length', () {
      final code = InviteCodeGenerator.generate();
      expect(code.length, 6);
    });
  });

  group('ShiftOverlapUtils', () {
    final baseDate = DateTime(2026, 6, 27);

    Shift shift({
      required String id,
      required int hour,
      int duration = 60,
      String userId = 'user-1',
    }) {
      final start = DateTime(baseDate.year, baseDate.month, baseDate.day, hour);
      return Shift(
        id: id,
        familyId: 'family-1',
        assignedUserId: userId,
        date: baseDate,
        startTime: TimeOfDay(hour: hour, minute: 0),
        durationMinutes: duration,
        endTime: start.add(Duration(minutes: duration)),
        status: ShiftStatus.scheduled,
        createdAt: start,
        updatedAt: start,
      );
    }

    test('detects overlapping shifts', () {
      final candidate = shift(id: 'c', hour: 10);
      final existing = [shift(id: 'e', hour: 10)];
      expect(ShiftOverlapUtils.hasOverlap(candidate, existing), isTrue);
    });

    test('allows non-overlapping shifts', () {
      final candidate = shift(id: 'c', hour: 12);
      final existing = [shift(id: 'e', hour: 10)];
      expect(ShiftOverlapUtils.hasOverlap(candidate, existing), isFalse);
    });

    test('detects double booking', () {
      final candidate = shift(id: 'c', hour: 10, userId: 'user-1');
      final existing = [shift(id: 'e', hour: 10, userId: 'user-1')];
      expect(ShiftOverlapUtils.hasDoubleBooking(candidate, existing), isTrue);
    });
  });
}
