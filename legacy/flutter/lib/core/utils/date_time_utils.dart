import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Date and time formatting helpers.
abstract final class DateTimeUtils {
  static DateTime dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }

  static DateTime combineDateAndTime(DateTime date, TimeOfDay time) {
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  static String formatDate(DateTime date) => DateFormat.yMMMd().format(date);

  static String formatMonthYear(DateTime date) =>
      DateFormat.yMMMM().format(DateTime(date.year, date.month));

  /// 24-hour clock, e.g. `14:30`.
  static String formatTime(DateTime dateTime) => DateFormat('HH:mm').format(dateTime);

  /// 24-hour clock for [TimeOfDay], e.g. `09:05`.
  static String formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Start and end time in 24-hour format, e.g. `14:30 – 16:30`.
  static String formatTimeRange(DateTime start, DateTime end) {
    return '${formatTime(start)} – ${formatTime(end)}';
  }

  static String formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }

  static DateTime startOfWeek(DateTime date) {
    final weekday = date.weekday;
    return dateOnly(date.subtract(Duration(days: weekday - 1)));
  }

  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6));
  }
}
