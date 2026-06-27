import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Resolved planner width for the signed-in user (defaults to 3 days).
final scheduleDaysShowedProvider = Provider<int>((ref) {
  final days =
      ref.watch(authStateProvider).valueOrNull?.scheduleDaysShowed ??
          ScheduleConstants.defaultDaysShowed;
  return ScheduleConstants.allowedDaysShowed.contains(days)
      ? days
      : ScheduleConstants.defaultDaysShowed;
});

/// Persists the user's preferred multi-day planner width in Firestore.
Future<Result<void>> updateScheduleDaysShowed(WidgetRef ref, int days) async {
  if (!ScheduleConstants.allowedDaysShowed.contains(days)) {
    return const Error(ValidationFailure('Invalid schedule view'));
  }

  final user = ref.read(authStateProvider).valueOrNull;
  if (user == null) {
    return const Error(AuthFailure('Not signed in'));
  }
  if (user.scheduleDaysShowed == days) {
    return const Success(null);
  }

  final result = await ref.read(authRepositoryProvider).updateUser(
        user.copyWith(scheduleDaysShowed: days),
      );

  return switch (result) {
    Success() => const Success(null),
    Error(:final failure) => Error(failure),
  };
}

String scheduleDaysShowedLabel(int days) => switch (days) {
      3 => '3 days',
      7 => '7 days',
      _ => '$days days',
    };
