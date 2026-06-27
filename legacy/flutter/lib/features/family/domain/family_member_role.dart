import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';

/// Roles and permissions for family members.
abstract final class FamilyMemberRole {
  static const owner = 'owner';
  static const manager = 'manager';
  static const member = 'member';

  static const assignableRoles = [member, manager];

  static bool canManageShifts(String role) =>
      role == owner || role == manager;

  static bool canManageMemberRoles(String role) => role == owner;

  static String label(String role) => switch (role) {
        owner => 'Owner',
        manager => 'Manager',
        _ => 'Member',
      };

  /// Firestore shift `assignedUserId` may reference a user id or member id.
  static String assignableId(FamilyMember member) => member.userId ?? member.id;

  static bool isShiftAssignedToUser({
    required Shift shift,
    required String? userId,
    required List<FamilyMember> members,
  }) {
    if (userId == null) return false;
    if (shift.assignedUserId == userId) return true;

    for (final member in members) {
      if (member.userId == userId && member.id == shift.assignedUserId) {
        return true;
      }
    }
    return false;
  }

  static bool canManageShift({
    required Shift shift,
    required String? userId,
    required List<FamilyMember> members,
  }) {
    final current = memberForUser(userId, members);
    if (current == null) return false;
    if (canManageShifts(current.role)) return true;
    return isShiftAssignedToUser(
      shift: shift,
      userId: userId,
      members: members,
    );
  }

  static FamilyMember? memberForUser(
    String? userId,
    List<FamilyMember> members,
  ) {
    if (userId == null) return null;
    for (final member in members) {
      if (member.userId == userId) return member;
    }
    return null;
  }
}
