import 'package:family_care_scheduler/core/utils/calendar_timezone.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CalendarTimezone', () {
    test('formatFloatingDateTime omits UTC offset', () {
      final value = DateTime(2026, 6, 27, 21, 5);

      expect(
        CalendarTimezone.formatFloatingDateTime(value),
        '2026-06-27T21:05:00',
      );
    });

    test('apiDateTime uses floating local time and IANA zone', () {
      final value = DateTime(2026, 6, 27, 21, 5);

      expect(
        CalendarTimezone.apiDateTime(value, 'Asia/Jerusalem'),
        {
          'dateTime': '2026-06-27T21:05:00',
          'timeZone': 'Asia/Jerusalem',
        },
      );
    });

    test('preferredSyncTimeZone prefers calendar over device', () {
      expect(
        CalendarTimezone.preferredSyncTimeZone(
          calendarTimeZone: 'Asia/Jerusalem',
          deviceTimeZone: 'GMT',
        ),
        'Asia/Jerusalem',
      );
    });

    test('shiftWallTimes uses duration from start', () {
      final shift = Shift(
        id: '1',
        familyId: 'f1',
        assignedUserId: 'u1',
        date: DateTime(2026, 6, 27),
        startTime: const TimeOfDay(hour: 21, minute: 5),
        durationMinutes: 120,
        endTime: DateTime(2026, 6, 28, 1, 5),
        createdAt: DateTime(2026, 6, 27),
        updatedAt: DateTime(2026, 6, 27),
      );

      final times = CalendarTimezone.shiftWallTimes(shift);

      expect(times.start.hour, 21);
      expect(times.start.minute, 5);
      expect(times.end.hour, 23);
      expect(times.end.minute, 5);
    });
  });
}
