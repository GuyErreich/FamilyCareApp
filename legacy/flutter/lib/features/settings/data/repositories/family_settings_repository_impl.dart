import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/features/auth/data/datasources/firestore_data_source.dart';
import 'package:family_care_scheduler/features/settings/data/dto/family_settings_dto.dart';
import 'package:family_care_scheduler/features/settings/domain/entities/family_settings.dart';
import 'package:family_care_scheduler/features/settings/domain/repositories/family_settings_repository.dart';

class FamilySettingsRepositoryImpl implements FamilySettingsRepository {
  FamilySettingsRepositoryImpl(this._firestore);

  final FirestoreDataSource _firestore;

  @override
  Stream<FamilySettings> watchFamilySettings(String familyId) =>
      _firestore.watchFamilySettings(familyId);

  @override
  Future<Result<FamilySettings>> saveFamilySettings(
    FamilySettings settings,
  ) async {
    try {
      await _firestore.setFamilySettings(
        settings.familyId,
        FamilySettingsDtoX.fromDomain(settings),
      );
      return Success(settings);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }
}
