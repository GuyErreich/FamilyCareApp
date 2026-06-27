import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/google_sign_in_provider.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_access.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_debug.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:timezone/timezone.dart' as tz;

final googleCalendarServiceProvider = Provider<GoogleCalendarService>(
  (ref) => GoogleCalendarService(ref.watch(googleSignInProvider)),
);

/// Syncs companion shifts with Google Calendar.
class GoogleCalendarService {
  GoogleCalendarService(this._googleSignIn);

  final GoogleSignIn _googleSignIn;

  /// Runs [action] with a Calendar API client, retrying once after scope approval.
  Future<Result<T>> _withCalendarApi<T>(
    Future<T> Function(calendar.CalendarApi api) action, {
    required String debugLabel,
  }) async {
    for (var attempt = 0; attempt < 2; attempt++) {
      if (attempt > 0) {
        googleCalendarDebug('Re-running $debugLabel after calendar approval');
      }

      final granted = await requestGoogleCalendarAccess(_googleSignIn);
      if (!granted) {
        googleCalendarDebug('$debugLabel aborted: calendar scope not granted');
        return const Error(
          CalendarFailure(
            'Calendar permission was denied. Allow calendar access when prompted.',
          ),
        );
      }

      final client = await buildCalendarAuthClient(_googleSignIn);
      if (client == null) {
        googleCalendarDebug('$debugLabel aborted: no auth client');
        return const Error(
          CalendarFailure('Could not authorize Google Calendar access.'),
        );
      }

      final api = calendar.CalendarApi(client);
      try {
        final result = await action(api);
        return Success(result);
      } catch (e, st) {
        if (attempt == 0 && isGoogleCalendarAuthError(e)) {
          googleCalendarDebug(
            '$debugLabel failed with auth error; retrying after refresh',
            error: e,
            stackTrace: st,
          );
          await refreshGoogleAuthAfterScopeGrant(_googleSignIn);
          continue;
        }

        googleCalendarDebug('$debugLabel failed', error: e, stackTrace: st);
        return Error(toCalendarFailure(e));
      }
    }

    return const Error(
      CalendarFailure('Calendar request failed after approval retry.'),
    );
  }

  Future<Result<String>> syncShift(Shift shift) async {
    googleCalendarDebug(
      'Syncing shift ${shift.id} '
      '(${shift.startDateTime} – ${shift.endDateTime})',
    );

    final timeZone = tz.local.name;
    final event = calendar.Event(
      summary: 'Companion shift',
      description: shift.notes,
      start: calendar.EventDateTime(
        dateTime: shift.startDateTime,
        timeZone: timeZone,
      ),
      end: calendar.EventDateTime(
        dateTime: shift.endDateTime,
        timeZone: timeZone,
      ),
    );

    return _withCalendarApi(
      (api) async {
        if (shift.calendarEventId != null) {
          googleCalendarDebug('Updating event ${shift.calendarEventId}');
          final updated = await api.events.update(
            event,
            'primary',
            shift.calendarEventId!,
          );
          final eventId = updated.id;
          if (eventId == null) {
            throw StateError('Google Calendar did not return an event id.');
          }
          googleCalendarDebug('Updated calendar event $eventId');
          return eventId;
        }

        googleCalendarDebug('Inserting event on primary calendar (tz=$timeZone)');
        final created = await api.events.insert(event, 'primary');
        final eventId = created.id;
        if (eventId == null) {
          throw StateError('Google Calendar did not return an event id.');
        }
        googleCalendarDebug('Created calendar event $eventId');
        return eventId;
      },
      debugLabel: 'syncShift',
    );
  }

  Future<void> deleteEvent(String eventId) async {
    googleCalendarDebug('Deleting calendar event $eventId');

    final result = await _withCalendarApi(
      (api) => api.events.delete('primary', eventId),
      debugLabel: 'deleteEvent',
    );

    if (result is Success<void>) {
      googleCalendarDebug('Deleted calendar event $eventId');
    } else if (result is Error<void>) {
      googleCalendarDebug('Delete aborted', error: result.failure.message);
    }
  }

  /// Requests Google Calendar access and verifies the API works.
  Future<Result<void>> connect() async {
    googleCalendarDebug('Connect requested');

    final result = await _withCalendarApi(
      (api) => api.events.list('primary', maxResults: 1),
      debugLabel: 'connect',
    );

    return switch (result) {
      Success() => const Success(null),
      Error(:final failure) => Error(failure),
    };
  }
}
