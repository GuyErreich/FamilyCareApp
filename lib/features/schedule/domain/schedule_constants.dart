/// Layout and interaction defaults for family schedule views.
abstract final class ScheduleConstants {
  static const int startHour = 6;
  static const int endHour = 22;
  static const int defaultDurationMinutes = 120;
  static const int snapMinutes = 30;
  static const double heightPerMinute = 1.05;
  static const double daySeparationWidth = 8;

  static double scrollOffsetForHour(int hour) => heightPerMinute * hour * 60;

  static double initialScrollOffset() {
    final now = DateTime.now();
    final targetMinutes = now.hour * 60 + now.minute - 45;
    final minMinutes = startHour * 60;
    final maxMinutes = endHour * 60 - 90;
    return heightPerMinute * targetMinutes.clamp(minMinutes, maxMinutes);
  }
}
