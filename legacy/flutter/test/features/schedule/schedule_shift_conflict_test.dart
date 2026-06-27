import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_quick_add_sheet.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_shift_conflict.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Shift _shift({
  required String id,
  required DateTime date,
  required int startHour,
  int durationMinutes = 120,
}) {
  final start = TimeOfDay(hour: startHour, minute: 0);
  final startDt = DateTime(date.year, date.month, date.day, startHour);
  return Shift(
    id: id,
    familyId: 'family',
    assignedUserId: 'user-1',
    date: date,
    startTime: start,
    durationMinutes: durationMinutes,
    endTime: startDt.add(Duration(minutes: durationMinutes)),
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
}

void main() {
  group('ScheduleShiftConflict', () {
    test('detects overlap with existing shift', () {
      final day = DateTime(2026, 6, 15);
      final selection = ScheduleSlotSelection(
        date: day,
        start: const TimeOfDay(hour: 9, minute: 0),
        durationMinutes: 120,
      );

      expect(
        ScheduleShiftConflict.hasOverlap(
          selection: selection,
          shifts: [_shift(id: 'a', date: day, startHour: 10)],
        ),
        isTrue,
      );
    });

    test('allows non-overlapping slot', () {
      final day = DateTime(2026, 6, 15);
      final selection = ScheduleSlotSelection(
        date: day,
        start: const TimeOfDay(hour: 9, minute: 0),
        durationMinutes: 120,
      );

      expect(
        ScheduleShiftConflict.hasOverlap(
          selection: selection,
          shifts: [_shift(id: 'a', date: day, startHour: 12)],
        ),
        isFalse,
      );
    });
  });

  testWidgets('quick add sheet disables Continue when slot conflicts',
      (tester) async {
    final day = DateTimeUtils.dateOnly(DateTime.now());

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showScheduleQuickAddSheet(
                    context,
                    initialDate: day,
                    allowPlaceOnCalendar: false,
                    existingShifts: [
                      _shift(id: 'a', date: day, startHour: 9),
                    ],
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Overlaps with'), findsOneWidget);
    final continueButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Continue'),
    );
    expect(continueButton.onPressed, isNull);
  });
}
