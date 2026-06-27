import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_slot_actions_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('slot actions sheet opens and Continue invokes callback',
      (tester) async {
    String? confirmedAssignee;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showScheduleSlotActionsSheet(
                    context,
                    selection: ScheduleSlotSelection(
                      date: DateTime(2026, 6, 15),
                      start: const TimeOfDay(hour: 9, minute: 0),
                      durationMinutes: 120,
                    ),
                    members: const [],
                    currentUserId: 'user-1',
                    canManageOthers: false,
                    onConfirmShift: (id) => confirmedAssignee = id,
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

    expect(find.text('Assign yourself'), findsOneWidget);
    expect(
      find.textContaining(DateTimeUtils.formatDate(DateTime(2026, 6, 15))),
      findsOneWidget,
    );

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(confirmedAssignee, 'user-1');
  });
}
