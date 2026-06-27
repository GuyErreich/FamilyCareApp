import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
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
    _initialized = true;
  }

  Future<void> scheduleShiftReminders(Shift shift) async {
    await initialize();
    await cancelShiftReminders(shift.id);

    for (var i = 0; i < shift.reminderOffsets.length; i++) {
      final fireAt = shift.startDateTime.subtract(shift.reminderOffsets[i]);
      if (fireAt.isBefore(DateTime.now())) continue;

      await _plugin.zonedSchedule(
        _notificationId(shift.id, i),
        'Upcoming companion shift',
        'Your shift starts at ${DateTimeUtils.formatTime(shift.startDateTime)}',
        tz.TZDateTime.from(fireAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'shift_reminders',
            'Shift reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelShiftReminders(String shiftId) async {
    for (var i = 0; i < 5; i++) {
      await _plugin.cancel(_notificationId(shiftId, i));
    }
  }

  int _notificationId(String shiftId, int index) =>
      shiftId.hashCode.abs() + index;
}
