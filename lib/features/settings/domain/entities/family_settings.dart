import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_settings.freezed.dart';

/// Per-family scheduling preferences stored at `settings/{familyId}`.
@freezed
class FamilySettings with _$FamilySettings {
  const factory FamilySettings({
    required String familyId,
    @Default(<String>[]) List<String> coverageFallbackUserIds,
    required DateTime updatedAt,
  }) = _FamilySettings;
}
