import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/presentation/month/schedule_month_grid.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ScheduleMonthGrid renders 42 day cells', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleMonthGrid(
            shifts: const [],
            members: const <FamilyMember>[],
            initialMonth: DateTime(2026, 6),
          ),
        ),
      ),
    );

    expect(find.text('Mon'), findsOneWidget);
    expect(find.text('Sun'), findsOneWidget);
    expect(find.text('1'), findsWidgets);
  });

  testWidgets('ScheduleMonthGrid invokes onDayTap', (tester) async {
    DateTime? tapped;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ScheduleMonthGrid(
            shifts: const [],
            members: const <FamilyMember>[],
            initialMonth: DateTime(2026, 6, 1),
            onDayTap: (day) => tapped = day,
          ),
        ),
      ),
    );

    await tester.tap(find.text('15').first);
    await tester.pump();

    expect(tapped, isNotNull);
    expect(tapped!.day, 15);
    expect(tapped!.month, 6);
  });
}
