import 'package:family_care_scheduler/features/schedule/presentation/schedule_member_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('scheduleMemberFilterProvider defaults to all', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(scheduleMemberFilterProvider),
      ScheduleMemberFilter.all,
    );
  });

  test('scheduleMemberFilterProvider toggles to mineOnly', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(scheduleMemberFilterProvider.notifier).state =
        ScheduleMemberFilter.mineOnly;

    expect(
      container.read(scheduleMemberFilterProvider),
      ScheduleMemberFilter.mineOnly,
    );
  });
}
