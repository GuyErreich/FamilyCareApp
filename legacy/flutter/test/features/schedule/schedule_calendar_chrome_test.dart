import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_toolbar.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_month_year_picker.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_plan_mode_bar.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SchedulePlanModeBar', () {
    testWidgets('switches mode on segment tap', (tester) async {
      ScheduleViewMode? picked;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SchedulePlanModeBar(
              mode: ScheduleViewMode.calendar,
              onModeChanged: (mode) => picked = mode,
            ),
          ),
        ),
      );

      expect(find.text('Day'), findsOneWidget);
      expect(find.text('Week'), findsOneWidget);
      expect(find.text('Calendar'), findsOneWidget);

      await tester.tap(find.text('Week'));
      expect(picked, ScheduleViewMode.week);
    });
  });

  group('ScheduleCalendarToolbar', () {
    testWidgets('renders label and actions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCalendarToolbar(
              label: 'June 2026',
              onPrevious: () {},
              onNext: () {},
              onToday: () {},
              onLabelTap: () {},
              mineFilterActive: true,
              onMineFilterTap: () {},
              onUpcomingTap: () {},
              onQuickAddTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('June 2026'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('showScheduleMonthYearPicker', () {
    testWidgets('applies month on Done', (tester) async {
      DateTime? picked;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return FilledButton(
                  onPressed: () async {
                    picked = await showScheduleMonthYearPicker(
                      context,
                      initial: DateTime(2026, 6, 15),
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

      expect(find.text('Go to month'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(picked, DateTime(2026, 6));
    });
  });
}
