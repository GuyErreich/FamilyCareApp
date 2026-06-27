/// Layout and interaction defaults for family schedule views.
abstract final class ScheduleConstants {
  /// Care day starts at 06:00; timeline shows through midnight (full 6→6 cycle).
  static const int dayStartHour = 6;
  static const int minutesPerDay = 24 * 60;
  static const int defaultDurationMinutes = 120;

  /// Drag, resize, and slot placement snap to this interval.
  static const int snapMinutes = 15;

  /// Planner grid rows alternate every [snapMinutes].
  static const int gridRowMinutes = snapMinutes;

  static const double heightPerMinute = 1.05;
  static const double daySeparationWidth = 1;

  /// Default planner columns when the user has not set a preference.
  static const int defaultDaysShowed = 3;

  /// Supported multi-day planner widths.
  static const List<int> allowedDaysShowed = [3, 7];

  static double scrollOffsetForMinutes(int minutes) => heightPerMinute * minutes;

  /// Snaps [dateTime] to the nearest [snapMinutes] on its calendar day.
  static DateTime snapToGrid(DateTime dateTime) {
    final day = DateTime(dateTime.year, dateTime.month, dateTime.day);
    var minutes = dateTime.hour * 60 + dateTime.minute;
    minutes = (minutes / snapMinutes).round() * snapMinutes;
    minutes = minutes.clamp(0, minutesPerDay - snapMinutes);
    return day.add(Duration(minutes: minutes));
  }

  static double initialScrollOffset() {
    final now = DateTime.now();
    final targetMinutes = now.hour * 60 + now.minute - 45;
    final minMinutes = dayStartHour * 60;
    final maxMinutes = minutesPerDay - 90;
    return heightPerMinute * targetMinutes.clamp(minMinutes, maxMinutes);
  }
}
