import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';

/// Contract for companion unavailability blocks.
abstract interface class UnavailabilityRepository {
  Stream<List<Unavailability>> watchForRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
  });

  Future<Result<Unavailability>> create(Unavailability block);

  Future<Result<void>> delete(String id);
}
