import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final localNotificationServiceProvider = Provider<LocalNotificationService>(
  (ref) => LocalNotificationService(),
);

/// Schedules per-shift local reminders.
class LocalNotificationService {
  LocalNotificationService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  var _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> scheduleShiftReminders(Shift shift) async {
    try {
      await initialize();
      await cancelShiftReminders(shift.id);

      final scheduleMode = await _resolveAndroidScheduleMode();

      for (var i = 0; i < shift.reminderOffsets.length; i++) {
        final fireAt = shift.startDateTime.subtract(shift.reminderOffsets[i]);
        if (fireAt.isBefore(DateTime.now())) continue;

        await _scheduleReminder(
          shift: shift,
          index: i,
          fireAt: fireAt,
          scheduleMode: scheduleMode,
        );
      }
    } on PlatformException {
      // Reminders are best-effort; never block shift save flows.
    } catch (_) {
      // Reminders are best-effort; never block shift save flows.
    }
  }

  Future<void> cancelShiftReminders(String shiftId) async {
    for (var i = 0; i < 5; i++) {
      await _plugin.cancel(_notificationId(shiftId, i));
    }
  }

  Future<AndroidScheduleMode> _resolveAndroidScheduleMode() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    if (await androidPlugin.canScheduleExactNotifications() == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    await androidPlugin.requestExactAlarmsPermission();
    if (await androidPlugin.canScheduleExactNotifications() == true) {
      return AndroidScheduleMode.exactAllowWhileIdle;
    }

    return AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> _scheduleReminder({
    required Shift shift,
    required int index,
    required DateTime fireAt,
    required AndroidScheduleMode scheduleMode,
  }) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'shift_reminders',
        'Shift reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );
    final scheduledTime = tz.TZDateTime.from(fireAt, tz.local);
    final notificationId = _notificationId(shift.id, index);
    final body =
        'Your shift starts at ${DateTimeUtils.formatTime(shift.startDateTime)}';

    try {
      await _plugin.zonedSchedule(
        notificationId,
        'Upcoming companion shift',
        body,
        scheduledTime,
        details,
        androidScheduleMode: scheduleMode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } on PlatformException catch (e) {
      if (e.code != 'exact_alarms_not_permitted' ||
          scheduleMode != AndroidScheduleMode.exactAllowWhileIdle) {
        rethrow;
      }

      await _plugin.zonedSchedule(
        notificationId,
        'Upcoming companion shift',
        body,
        scheduledTime,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  int _notificationId(String shiftId, int index) =>
      shiftId.hashCode.abs() + index;
}
