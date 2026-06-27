import 'package:family_care_scheduler/features/settings/domain/usecases/coverage_fallback_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CoverageFallbackResolver', () {
    test('picks the next person after the dropped companion', () {
      const chain = ['a', 'b', 'c', 'd'];

      final plan = CoverageFallbackResolver.plan(
        chainUserIds: chain,
        droppedUserId: 'b',
      );

      expect(plan.primaryUserId, 'c');
      expect(plan.backupUserIds, ['d']);
    });

    test('wraps to earlier backups when dropped companion is last', () {
      const chain = ['a', 'b', 'c'];

      final plan = CoverageFallbackResolver.plan(
        chainUserIds: chain,
        droppedUserId: 'c',
      );

      expect(plan.primaryUserId, 'a');
      expect(plan.backupUserIds, ['b']);
    });

    test('uses chain start when dropped companion is not listed', () {
      const chain = ['a', 'b', 'c'];

      final plan = CoverageFallbackResolver.plan(
        chainUserIds: chain,
        droppedUserId: 'z',
      );

      expect(plan.primaryUserId, 'a');
      expect(plan.backupUserIds, ['b', 'c']);
    });
  });
}
