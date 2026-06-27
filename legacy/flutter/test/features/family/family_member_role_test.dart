import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final createdAt = DateTime(2026, 6, 27);

  group('FamilyMemberRole', () {
    test('canManageShifts includes owner and manager', () {
      expect(FamilyMemberRole.canManageShifts(FamilyMemberRole.owner), isTrue);
      expect(FamilyMemberRole.canManageShifts(FamilyMemberRole.manager), isTrue);
      expect(FamilyMemberRole.canManageShifts(FamilyMemberRole.member), isFalse);
    });

    test('isShiftAssignedToUser matches user id or member id', () {
      final member = FamilyMember(
        id: 'member-1',
        familyId: 'family-1',
        userId: 'user-1',
        name: 'Alex',
        colorHex: '#000000',
        createdAt: createdAt,
      );
      final shift = Shift(
        id: 'shift-1',
        familyId: 'family-1',
        assignedUserId: 'member-1',
        date: createdAt,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        durationMinutes: 60,
        endTime: createdAt.add(const Duration(hours: 1)),
        status: ShiftStatus.scheduled,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(
        FamilyMemberRole.isShiftAssignedToUser(
          shift: shift,
          userId: 'user-1',
          members: [member],
        ),
        isTrue,
      );
      expect(
        FamilyMemberRole.isShiftAssignedToUser(
          shift: shift,
          userId: 'other-user',
          members: [member],
        ),
        isFalse,
      );
    });

    test('canManageShift allows managers to edit any shift', () {
      final manager = FamilyMember(
        id: 'manager-1',
        familyId: 'family-1',
        userId: 'manager-user',
        name: 'Manager',
        colorHex: '#000000',
        role: FamilyMemberRole.manager,
        createdAt: createdAt,
      );
      final member = FamilyMember(
        id: 'member-1',
        familyId: 'family-1',
        userId: 'user-1',
        name: 'Alex',
        colorHex: '#000000',
        createdAt: createdAt,
      );
      final shift = Shift(
        id: 'shift-1',
        familyId: 'family-1',
        assignedUserId: 'member-1',
        date: createdAt,
        startTime: const TimeOfDay(hour: 9, minute: 0),
        durationMinutes: 60,
        endTime: createdAt.add(const Duration(hours: 1)),
        status: ShiftStatus.scheduled,
        createdAt: createdAt,
        updatedAt: createdAt,
      );

      expect(
        FamilyMemberRole.canManageShift(
          shift: shift,
          userId: 'manager-user',
          members: [manager, member],
        ),
        isTrue,
      );
      expect(
        FamilyMemberRole.canManageShift(
          shift: shift,
          userId: 'user-1',
          members: [manager, member],
        ),
        isTrue,
      );
      expect(
        FamilyMemberRole.canManageShift(
          shift: shift,
          userId: 'stranger',
          members: [manager, member],
        ),
        isFalse,
      );
    });
  });
}
