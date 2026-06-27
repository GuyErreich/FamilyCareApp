/// Application-wide string constants.
abstract final class AppConstants {
  static const String appName = 'Family Care Scheduler';
  static const int inviteCodeLength = 6;
  static const double tabletBreakpoint = 600;

  /// Web OAuth client ID from Firebase (required for Google Sign-In + Firebase Auth).
  static const String googleWebClientId =
      '388117547421-fufsuan14l8gb8sr07cmc8apb1kvto9o.apps.googleusercontent.com';

  static const List<Duration> defaultReminderOffsets = [
    Duration(days: 1),
    Duration(hours: 1),
    Duration(minutes: 15),
  ];
}
