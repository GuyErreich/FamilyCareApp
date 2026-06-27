import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final familyMembersProvider = StreamProvider<List<FamilyMember>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  return ref.watch(familyRepositoryProvider).watchMembers(user!.familyId!);
});

/// Signed-in user's row in [familyMembersProvider], if linked.
final currentFamilyMemberProvider = Provider<FamilyMember?>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  final members = ref.watch(familyMembersProvider).valueOrNull;
  if (user == null || members == null) return null;
  return FamilyMemberRole.memberForUser(user.id, members);
});

/// Owners and managers can schedule shifts for anyone in the family.
final canManageFamilyShiftsProvider = Provider<bool>((ref) {
  final member = ref.watch(currentFamilyMemberProvider);
  if (member == null) return false;
  return FamilyMemberRole.canManageShifts(member.role);
});

/// Only the family owner can promote members to manager.
final canManageMemberRolesProvider = Provider<bool>((ref) {
  final member = ref.watch(currentFamilyMemberProvider);
  if (member == null) return false;
  return FamilyMemberRole.canManageMemberRoles(member.role);
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

/// Shifts visible in a multi-day planner window starting at [start].
final rangeShiftsProvider =
    StreamProvider.family<List<Shift>, (DateTime start, int dayCount)>(
        (ref, range) {
  final (start, dayCount) = range;
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  final end = start.add(Duration(days: dayCount - 1));
  return ref.watch(shiftRepositoryProvider).watchShiftsForRange(
        familyId: user!.familyId!,
        start: start,
        end: end,
      );
});

final monthShiftsProvider =
    StreamProvider.family<List<Shift>, DateTime>((ref, month) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  final start = DateTime(month.year, month.month);
  final end = DateTime(month.year, month.month + 1, 0);
  return ref.watch(shiftRepositoryProvider).watchShiftsForRange(
        familyId: user!.familyId!,
        start: start,
        end: end,
      );
});
