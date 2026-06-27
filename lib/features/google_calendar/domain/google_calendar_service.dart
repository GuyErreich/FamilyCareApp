import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

final googleCalendarServiceProvider = Provider<GoogleCalendarService>(
  (ref) => GoogleCalendarService(GoogleSignIn(scopes: [calendar.CalendarApi.calendarScope])),
);

/// Syncs companion shifts with Google Calendar.
class GoogleCalendarService {
  GoogleCalendarService(this._googleSignIn);

  final GoogleSignIn _googleSignIn;

  Future<calendar.CalendarApi?> _api() async {
    final client = await _googleSignIn.authenticatedClient();
    return client == null ? null : calendar.CalendarApi(client);
  }

  Future<String?> syncShift(Shift shift) async {
    final api = await _api();
    if (api == null) return null;

    final event = calendar.Event(
      summary: 'Companion shift',
      description: shift.notes,
      start: calendar.EventDateTime(
        dateTime: shift.startDateTime.toUtc(),
        timeZone: 'UTC',
      ),
      end: calendar.EventDateTime(
        dateTime: shift.endDateTime.toUtc(),
        timeZone: 'UTC',
      ),
    );

    if (shift.calendarEventId != null) {
      final updated = await api.events.update(
        event,
        'primary',
        shift.calendarEventId!,
      );
      return updated.id;
    }

    final created = await api.events.insert(event, 'primary');
    return created.id;
  }

  Future<void> deleteEvent(String eventId) async {
    final api = await _api();
    if (api == null) return;
    await api.events.delete('primary', eventId);
  }
}
