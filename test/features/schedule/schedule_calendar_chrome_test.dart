import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_toolbar.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_month_year_picker.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScheduleCalendarToolbar', () {
    testWidgets('renders label and view mode icon', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCalendarToolbar(
              label: 'June 2026',
              viewMode: ScheduleViewMode.week,
              onPrevious: () {},
              onNext: () {},
              onToday: () {},
              onLabelTap: () {},
              onViewModeTap: () {},
              onViewModeLongPress: () {},
            ),
          ),
        ),
      );

      expect(find.text('June 2026'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);
      expect(find.byIcon(Icons.view_week), findsOneWidget);
    });

    testWidgets('view mode tap fires callback', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ScheduleCalendarToolbar(
              label: 'June 2026',
              viewMode: ScheduleViewMode.threeDay,
              onPrevious: () {},
              onNext: () {},
              onToday: () {},
              onLabelTap: () {},
              onViewModeTap: () => tapped = true,
              onViewModeLongPress: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.view_day));
      expect(tapped, isTrue);
    });
  });

  group('showScheduleMonthYearPicker', () {
    testWidgets('applies month on chip tap and closes', (tester) async {
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
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(picked, DateTime(2026, 6));
    });
  });
}
