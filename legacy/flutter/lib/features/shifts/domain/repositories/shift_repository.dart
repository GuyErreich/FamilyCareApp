import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';

/// Contract for shift schedule operations.
abstract interface class ShiftRepository {
  Stream<List<Shift>> watchShiftsForDay({
    required String familyId,
    required DateTime date,
  });

  Stream<List<Shift>> watchShiftsForRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
  });

  Future<Result<Shift>> getShift(String shiftId);

  Future<Result<List<Shift>>> getShiftsForDay({
    required String familyId,
    required DateTime date,
  });

  Future<Result<Shift>> createShift(Shift shift);

  Future<Result<Shift>> updateShift(Shift shift);

  Future<Result<void>> deleteShift(String shiftId);
}
