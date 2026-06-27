import 'package:equatable/equatable.dart';

/// Base type for domain and infrastructure failures.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Authentication-related failure.
final class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Firestore or network failure.
final class DataFailure extends Failure {
  const DataFailure(super.message);
}

/// Shift validation failure.
final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Google Calendar sync failure.
final class CalendarFailure extends Failure {
  const CalendarFailure(super.message);
}
