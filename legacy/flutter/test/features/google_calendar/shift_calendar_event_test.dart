import 'package:family_care_scheduler/features/google_calendar/domain/shift_calendar_event.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ShiftCalendarEvent', () {
    test('summary includes family, care recipient, and companion', () {
      expect(
        ShiftCalendarEvent.summary(
          familyName: 'Smith Family',
          careRecipientName: 'Grandpa Joe',
          companionName: 'Alex',
        ),
        'Companion shift · Smith Family · for Grandpa Joe · with Alex',
      );
    });

    test('description includes schedule and notes', () {
      final shift = Shift(
        id: '1',
        familyId: 'f1',
        assignedUserId: 'u1',
        date: DateTime(2026, 6, 27),
        startTime: const TimeOfDay(hour: 14, minute: 30),
        durationMinutes: 120,
        endTime: DateTime(2026, 6, 27, 16, 30),
        notes: 'Bring lunch',
        createdAt: DateTime(2026, 6, 27),
        updatedAt: DateTime(2026, 6, 27),
      );

      final description = ShiftCalendarEvent.description(
        shift: shift,
        familyName: 'Smith Family',
        careRecipientName: 'Grandpa Joe',
        companionName: 'Alex',
      );

      expect(description, contains('14:30 – 16:30'));
      expect(description, contains('Family: Smith Family'));
      expect(description, contains('Care recipient: Grandpa Joe'));
      expect(description, contains('Companion: Alex'));
      expect(description, contains('Bring lunch'));
    });
  });
}
