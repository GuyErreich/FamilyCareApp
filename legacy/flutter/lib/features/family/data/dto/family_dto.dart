import 'package:family_care_scheduler/features/auth/data/dto/app_user_dto.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_dto.freezed.dart';
part 'family_dto.g.dart';

@freezed
class FamilyDto with _$FamilyDto {
  const factory FamilyDto({
    required String name,
    required String grandpaName,
    required String inviteCode,
    @TimestampConverter() required DateTime createdAt,
    @TimestampConverter() required DateTime updatedAt,
  }) = _FamilyDto;

  factory FamilyDto.fromJson(Map<String, dynamic> json) =>
      _$FamilyDtoFromJson(json);
}

extension FamilyDtoX on FamilyDto {
  Family toDomain(String id) => Family(
        id: id,
        name: name,
        grandpaName: grandpaName,
        inviteCode: inviteCode,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  static FamilyDto fromDomain(Family family) => FamilyDto(
        name: family.name,
        grandpaName: family.grandpaName,
        inviteCode: family.inviteCode,
        createdAt: family.createdAt,
        updatedAt: family.updatedAt,
      );
}
