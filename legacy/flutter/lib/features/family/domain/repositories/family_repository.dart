import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';

/// Contract for family group and member operations.
abstract interface class FamilyRepository {
  Future<Result<Family>> createFamily({
    required String name,
    required String grandpaName,
    required String ownerUserId,
  });

  Future<Result<Family>> joinFamily({
    required String inviteCode,
    required String userId,
  });

  Future<Result<Family>> getFamily(String familyId);

  Stream<List<FamilyMember>> watchMembers(String familyId);

  Future<Result<FamilyMember>> addMember(FamilyMember member);

  Future<Result<FamilyMember>> updateMember(FamilyMember member);

  Future<Result<void>> deleteMember(String memberId);
}
