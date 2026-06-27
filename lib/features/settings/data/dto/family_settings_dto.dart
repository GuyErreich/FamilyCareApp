import 'package:family_care_scheduler/features/auth/data/dto/app_user_dto.dart';
import 'package:family_care_scheduler/features/settings/domain/entities/family_settings.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_settings_dto.freezed.dart';
part 'family_settings_dto.g.dart';

@freezed
class FamilySettingsDto with _$FamilySettingsDto {
  const factory FamilySettingsDto({
    @Default(<String>[]) List<String> coverageFallbackUserIds,
    @TimestampConverter() required DateTime updatedAt,
  }) = _FamilySettingsDto;

  factory FamilySettingsDto.fromJson(Map<String, dynamic> json) =>
      _$FamilySettingsDtoFromJson(json);
}

extension FamilySettingsDtoX on FamilySettingsDto {
  FamilySettings toDomain(String familyId) => FamilySettings(
        familyId: familyId,
        coverageFallbackUserIds: coverageFallbackUserIds,
        updatedAt: updatedAt,
      );

  static FamilySettingsDto fromDomain(FamilySettings settings) =>
      FamilySettingsDto(
        coverageFallbackUserIds: settings.coverageFallbackUserIds,
        updatedAt: settings.updatedAt,
      );
}
