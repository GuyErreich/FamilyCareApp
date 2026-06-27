import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final rangeUnavailabilitiesProvider =
    StreamProvider.family<List<Unavailability>, (DateTime start, int dayCount)>(
        (ref, range) {
  final (start, dayCount) = range;
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  final end = start.add(Duration(days: dayCount - 1));
  return ref.watch(unavailabilityRepositoryProvider).watchForRange(
        familyId: user!.familyId!,
        start: start,
        end: end,
      );
});

final dayUnavailabilitiesProvider =
    StreamProvider.family<List<Unavailability>, DateTime>((ref, day) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  return ref.watch(unavailabilityRepositoryProvider).watchForRange(
        familyId: user!.familyId!,
        start: day,
        end: day,
      );
});

final monthUnavailabilitiesProvider =
    StreamProvider.family<List<Unavailability>, DateTime>((ref, month) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  final start = DateTime(month.year, month.month);
  final end = DateTime(month.year, month.month + 1, 0);
  return ref.watch(unavailabilityRepositoryProvider).watchForRange(
        familyId: user!.familyId!,
        start: start,
        end: end,
      );
});
