import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_debug.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Resolves the device IANA timezone for Google Calendar and local scheduling.
abstract final class CalendarTimezone {
  static var _initialized = false;
  static String? _cachedName;

  /// Ensures timezone data is loaded and [tz.local] matches the device zone.
  static Future<String> localTimeZoneName({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedName != null) return _cachedName!;

    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }

    try {
      final info = await FlutterTimezone.getLocalTimezone();
      final name = _resolveLocationName(info.identifier);
      _cachedName = name;
      tz.setLocalLocation(tz.getLocation(name));
      googleCalendarDebug('Resolved device timezone: $name');
      return name;
    } catch (e, st) {
      googleCalendarDebug(
        'Timezone lookup failed; using DateTime local offset',
        error: e,
        stackTrace: st,
      );
      final fallback = DateTime.now().timeZoneName;
      _cachedName = fallback;
      try {
        tz.setLocalLocation(tz.getLocation(fallback));
      } catch (_) {
        tz.setLocalLocation(tz.UTC);
        _cachedName = 'UTC';
      }
      return _cachedName!;
    }
  }

  static String _resolveLocationName(String identifier) {
    try {
      tz.getLocation(identifier);
      return identifier;
    } catch (_) {
      // Some platforms report legacy aliases.
      const aliases = <String, String>{
        'Asia/Tel_Aviv': 'Asia/Jerusalem',
        'Europe/Kiev': 'Europe/Kyiv',
      };
      final mapped = aliases[identifier];
      if (mapped != null) {
        tz.getLocation(mapped);
        return mapped;
      }
      rethrow;
    }
  }

  /// Wall-clock start/end for a shift using stored date + time fields.
  static ({DateTime start, DateTime end}) shiftWallTimes(Shift shift) {
    final start = wallClock(shift.startDateTime);
    return (
      start: start,
      end: start.add(Duration(minutes: shift.durationMinutes)),
    );
  }

  /// Labels shift wall-clock times with the Google Calendar timezone.
  ///
  /// Companion shifts are family-local times (21:05 means 21:05 where care
  /// happens). The primary calendar timezone matches how Google displays events,
  /// which may differ from the device — especially on emulators defaulting to GMT.
  static String preferredSyncTimeZone({
    required String calendarTimeZone,
    required String deviceTimeZone,
  }) {
    _validateTimeZone(calendarTimeZone);

    if (calendarTimeZone != deviceTimeZone) {
      googleCalendarDebug(
        'Calendar sync timezone: $calendarTimeZone '
        '(device timezone is $deviceTimeZone)',
      );
    }

    return calendarTimeZone;
  }

  static void _validateTimeZone(String name) {
    if (!_initialized) {
      tz_data.initializeTimeZones();
      _initialized = true;
    }
    tz.getLocation(_resolveLocationName(name));
  }

  /// Strips timezone offset so calendar fields use wall-clock components.
  static DateTime wallClock(DateTime value) => DateTime(
        value.year,
        value.month,
        value.day,
        value.hour,
        value.minute,
        value.second,
      );

  /// Google Calendar `start` / `end` object using floating local time + IANA zone.
  static Map<String, String> apiDateTime(DateTime wallClock, String timeZone) {
    return {
      'dateTime': formatFloatingDateTime(wallClock),
      'timeZone': timeZone,
    };
  }

  /// RFC3339-like local timestamp without offset, as required by Calendar API.
  static String formatFloatingDateTime(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    final second = value.second.toString().padLeft(2, '0');
    return '$year-$month-$day' 'T' '$hour:$minute:$second';
  }
}
