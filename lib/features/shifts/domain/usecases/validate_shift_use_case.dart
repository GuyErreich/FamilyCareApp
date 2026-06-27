import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/utils/shift_overlap_utils.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/repositories/shift_repository.dart';

/// Validates shift business rules before persistence.
class ValidateShiftUseCase {
  const ValidateShiftUseCase(this._shiftRepository);

  final ShiftRepository _shiftRepository;

  Future<Result<void>> call(Shift candidate) async {
    if (candidate.startDateTime.isBefore(DateTime.now())) {
      return const Error(ValidationFailure('Cannot schedule shifts in the past.'));
    }

    final dayShiftsResult = await _shiftRepository.getShiftsForDay(
      familyId: candidate.familyId,
      date: candidate.date,
    );

    if (dayShiftsResult is Error<List<Shift>>) {
      return Error(dayShiftsResult.failure);
    }

    final existing = (dayShiftsResult as Success<List<Shift>>).data;

    if (ShiftOverlapUtils.hasOverlap(candidate, existing)) {
      return const Error(
        ValidationFailure('This shift overlaps with an existing shift.'),
      );
    }

    if (ShiftOverlapUtils.hasDoubleBooking(candidate, existing)) {
      return const Error(
        ValidationFailure('This family member is already booked at this time.'),
      );
    }

    return const Success(null);
  }
}
