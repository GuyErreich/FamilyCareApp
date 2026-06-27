import 'package:family_care_scheduler/features/schedule/presentation/plan_view_mode_provider.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('planViewModeProvider defaults to calendar', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(planViewModeProvider),
      ScheduleViewMode.calendar,
    );
  });

  test('openPlanForDate sets day mode and jump date', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final date = DateTime(2026, 6, 15);

    container.read(planJumpDateProvider.notifier).state = date;
    container.read(planViewModeProvider.notifier).state = ScheduleViewMode.day;

    expect(container.read(planViewModeProvider), ScheduleViewMode.day);
    expect(container.read(planJumpDateProvider), date);
  });
}
