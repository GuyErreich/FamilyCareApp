import 'package:family_care_scheduler/features/auth/data/dto/app_user_dto.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_member_dto.freezed.dart';
part 'family_member_dto.g.dart';

@freezed
class FamilyMemberDto with _$FamilyMemberDto {
  const factory FamilyMemberDto({
    required String familyId,
    String? userId,
    required String name,
    String? phone,
    required String colorHex,
    String? avatarUrl,
    @Default('member') String role,
    @TimestampConverter() required DateTime createdAt,
  }) = _FamilyMemberDto;

  factory FamilyMemberDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyMemberDtoFromJson(json);
}

extension FamilyMemberDtoX on FamilyMemberDto {
  FamilyMember toDomain(String id) => FamilyMember(
        id: id,
        familyId: familyId,
        userId: userId,
        name: name,
        phone: phone,
        colorHex: colorHex,
        avatarUrl: avatarUrl,
        role: role,
        createdAt: createdAt,
      );

  static FamilyMemberDto fromDomain(FamilyMember member) => FamilyMemberDto(
        familyId: member.familyId,
        userId: member.userId,
        name: member.name,
        phone: member.phone,
        colorHex: member.colorHex,
        avatarUrl: member.avatarUrl,
        role: member.role,
        createdAt: member.createdAt,
      );
}
