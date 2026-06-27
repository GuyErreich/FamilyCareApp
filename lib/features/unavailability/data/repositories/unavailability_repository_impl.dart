import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/data/datasources/firestore_data_source.dart';
import 'package:family_care_scheduler/features/unavailability/data/dto/unavailability_dto.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:family_care_scheduler/features/unavailability/domain/repositories/unavailability_repository.dart';

class UnavailabilityRepositoryImpl implements UnavailabilityRepository {
  UnavailabilityRepositoryImpl(this._firestore);

  final FirestoreDataSource _firestore;

  @override
  Stream<List<Unavailability>> watchForRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
  }) =>
      _firestore.watchUnavailabilitiesForRange(
        familyId: familyId,
        start: DateTimeUtils.dateOnly(start),
        end: DateTimeUtils.dateOnly(end),
      );

  @override
  Future<Result<Unavailability>> create(Unavailability block) async {
    try {
      final created = await _firestore.createUnavailability(
        UnavailabilityDtoX.fromDomain(block),
      );
      return Success(created);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _firestore.deleteUnavailability(id);
      return const Success(null);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }
}
