import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/utils/invite_code_generator.dart';
import 'package:family_care_scheduler/features/auth/data/datasources/firestore_data_source.dart';
import 'package:family_care_scheduler/features/auth/data/dto/app_user_dto.dart';
import 'package:family_care_scheduler/features/family/data/dto/family_dto.dart';
import 'package:family_care_scheduler/features/family/data/dto/family_member_dto.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/domain/repositories/family_repository.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  FamilyRepositoryImpl(this._firestore);

  final FirestoreDataSource _firestore;

  @override
  Future<Result<Family>> createFamily({
    required String name,
    required String grandpaName,
    required String ownerUserId,
  }) async {
    try {
      final now = DateTime.now();
      final dto = FamilyDto(
        name: name,
        grandpaName: grandpaName,
        inviteCode: InviteCodeGenerator.generate(),
        createdAt: now,
        updatedAt: now,
      );
      final family = await _firestore.createFamily(dto);

      final owner = await _firestore.getUser(ownerUserId);
      if (owner != null) {
        await _firestore.setUser(
          ownerUserId,
          AppUserDtoX.fromDomain(owner.copyWith(familyId: family.id)),
        );
        await _firestore.addMember(
          FamilyMemberDto(
            familyId: family.id,
            userId: ownerUserId,
            name: owner.displayName ?? owner.email,
            phone: owner.phone,
            colorHex: owner.colorHex,
            avatarUrl: owner.avatarUrl,
            role: 'owner',
            createdAt: now,
          ),
        );
      }

      return Success(family);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Future<Result<Family>> joinFamily({
    required String inviteCode,
    required String userId,
  }) async {
    try {
      final family = await _firestore.getFamilyByInviteCode(inviteCode);
      if (family == null) {
        return const Error(DataFailure('Invalid invite code.'));
      }

      final user = await _firestore.getUser(userId);
      if (user == null) {
        return const Error(DataFailure('User profile not found.'));
      }

      await _firestore.setUser(
        userId,
        AppUserDtoX.fromDomain(user.copyWith(familyId: family.id)),
      );

      await _firestore.addMember(
        FamilyMemberDto(
          familyId: family.id,
          userId: userId,
          name: user.displayName ?? user.email,
          phone: user.phone,
          colorHex: user.colorHex,
          avatarUrl: user.avatarUrl,
          createdAt: DateTime.now(),
        ),
      );

      return Success(family);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Future<Result<Family>> getFamily(String familyId) async {
    try {
      final family = await _firestore.getFamily(familyId);
      if (family == null) {
        return const Error(DataFailure('Family not found.'));
      }
      return Success(family);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Stream<List<FamilyMember>> watchMembers(String familyId) =>
      _firestore.watchMembers(familyId);

  @override
  Future<Result<FamilyMember>> addMember(FamilyMember member) async {
    try {
      final created = await _firestore.addMember(
        FamilyMemberDtoX.fromDomain(member),
      );
      return Success(created);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Future<Result<FamilyMember>> updateMember(FamilyMember member) async {
    try {
      await _firestore.updateMember(
        member.id,
        FamilyMemberDtoX.fromDomain(member),
      );
      return Success(member);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteMember(String memberId) async {
    try {
      await _firestore.deleteMember(memberId);
      return const Success(null);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }
}
