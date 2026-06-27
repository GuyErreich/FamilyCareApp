import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/features/settings/domain/entities/family_settings.dart';

/// Contract for family-wide settings at `settings/{familyId}`.
abstract interface class FamilySettingsRepository {
  Stream<FamilySettings> watchFamilySettings(String familyId);

  Future<Result<FamilySettings>> saveFamilySettings(FamilySettings settings);
}
