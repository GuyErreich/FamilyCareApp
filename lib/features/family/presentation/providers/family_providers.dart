import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final familyMembersProvider = StreamProvider<List<FamilyMember>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  return ref.watch(familyRepositoryProvider).watchMembers(user!.familyId!);
});

final weekShiftsProvider =
    StreamProvider.family<List<Shift>, DateTime>((ref, weekStart) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  final end = weekStart.add(const Duration(days: 6));
  return ref.watch(shiftRepositoryProvider).watchShiftsForRange(
        familyId: user!.familyId!,
        start: weekStart,
        end: end,
      );
});
