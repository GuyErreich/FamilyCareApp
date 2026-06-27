import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/data/datasources/firestore_data_source.dart';
import 'package:family_care_scheduler/features/shifts/data/dto/shift_dto.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/repositories/shift_repository.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  ShiftRepositoryImpl(this._firestore);

  final FirestoreDataSource _firestore;

  @override
  Stream<List<Shift>> watchShiftsForDay({
    required String familyId,
    required DateTime date,
  }) {
    final start = DateTimeUtils.dateOnly(date);
    final end = start.add(const Duration(days: 1));
    return _firestore.watchShiftsForRange(
      familyId: familyId,
      start: start,
      end: end,
    );
  }

  @override
  Stream<List<Shift>> watchShiftsForRange({
    required String familyId,
    required DateTime start,
    required DateTime end,
  }) =>
      _firestore.watchShiftsForRange(
        familyId: familyId,
        start: DateTimeUtils.dateOnly(start),
        end: DateTimeUtils.dateOnly(end),
      );

  @override
  Future<Result<Shift>> getShift(String shiftId) async {
    try {
      final shift = await _firestore.getShift(shiftId);
      if (shift == null) {
        return const Error(DataFailure('Shift not found.'));
      }
      return Success(shift);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Shift>>> getShiftsForDay({
    required String familyId,
    required DateTime date,
  }) async {
    try {
      final shifts = await _firestore.getShiftsForDay(
        familyId: familyId,
        date: date,
      );
      return Success(shifts);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Future<Result<Shift>> createShift(Shift shift) async {
    try {
      final created = await _firestore.createShift(ShiftDtoX.fromDomain(shift));
      return Success(created);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Future<Result<Shift>> updateShift(Shift shift) async {
    try {
      await _firestore.updateShift(shift.id, ShiftDtoX.fromDomain(shift));
      return Success(shift);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteShift(String shiftId) async {
    try {
      await _firestore.deleteShift(shiftId);
      return const Success(null);
    } catch (e) {
      return Error(DataFailure(e.toString()));
    }
  }
}
