/// Application-wide string constants.
abstract final class AppConstants {
  static const String appName = 'Family Care Scheduler';
  static const int inviteCodeLength = 6;
  static const double tabletBreakpoint = 600;
  static const List<Duration> defaultReminderOffsets = [
    Duration(days: 1),
    Duration(hours: 1),
    Duration(minutes: 15),
  ];
}
