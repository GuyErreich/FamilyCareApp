import 'package:family_care_scheduler/core/utils/calendar_timezone.dart';
import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/google_sign_in_provider.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_access.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_debug.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_constants.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_event_api.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/shift_calendar_event.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/calendar/v3.dart' show DetailedApiRequestError;
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

final googleCalendarServiceProvider = Provider<GoogleCalendarService>(
  (ref) => GoogleCalendarService(ref.watch(googleSignInProvider)),
);

/// Syncs companion shifts with Google Calendar.
class GoogleCalendarService {
  GoogleCalendarService(this._googleSignIn);

  final GoogleSignIn _googleSignIn;
  String? _cachedCalendarTimeZone;

  /// Runs [action] with an authenticated Calendar HTTP client.
  Future<Result<T>> _withCalendarClient<T>(
    Future<T> Function(gapis.AuthClient client) action, {
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

      try {
        final result = await action(client);
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

  /// Runs [action] with a Calendar API client, retrying once after scope approval.
  Future<Result<T>> _withCalendarApi<T>(
    Future<T> Function(calendar.CalendarApi api) action, {
    required String debugLabel,
  }) async {
    return _withCalendarClient(
      (client) async {
        final api = calendar.CalendarApi(client);
        return action(api);
      },
      debugLabel: debugLabel,
    );
  }

  /// Returns the Google account used for calendar sync, if signed in.
  Future<String?> calendarAccountEmail() async {
    final account =
        _googleSignIn.currentUser ?? await _googleSignIn.signInSilently();
    return account?.email;
  }

  Future<Result<String>> syncShift(
    Shift shift, {
    String? familyName,
    String? careRecipientName,
    String? companionName,
  }) async {
    final wallTimes = CalendarTimezone.shiftWallTimes(shift);

    return _withCalendarClient(
      (client) async {
        final deviceTz = await CalendarTimezone.localTimeZoneName();
        final calendarTz = await _primaryCalendarTimeZone(client);
        final timeZone = CalendarTimezone.preferredSyncTimeZone(
          calendarTimeZone: calendarTz,
          deviceTimeZone: deviceTz,
        );

        googleCalendarDebug(
          'Syncing shift ${shift.id} '
          '(wall ${wallTimes.start} – ${wallTimes.end}, tz=$timeZone, '
          'deviceOffset=${DateTime.now().timeZoneOffset})',
        );

        final body = <String, dynamic>{
          'summary': ShiftCalendarEvent.summary(
            familyName: familyName,
            careRecipientName: careRecipientName,
            companionName: companionName,
          ),
          'description': ShiftCalendarEvent.description(
            shift: shift,
            familyName: familyName,
            careRecipientName: careRecipientName,
            companionName: companionName,
          ),
          'colorId': GoogleCalendarConstants.companionShiftColorId,
          'start': CalendarTimezone.apiDateTime(wallTimes.start, timeZone),
          'end': CalendarTimezone.apiDateTime(wallTimes.end, timeZone),
        };

        if (shift.calendarEventId != null) {
          googleCalendarDebug('Updating event ${shift.calendarEventId}');
          final eventId = await GoogleCalendarEventApi.update(
            client,
            shift.calendarEventId!,
            body,
          );
          googleCalendarDebug('Updated calendar event $eventId');
          return eventId;
        }

        googleCalendarDebug('Inserting event on primary calendar');
        final eventId = await GoogleCalendarEventApi.insert(client, body);
        googleCalendarDebug('Created calendar event $eventId');
        return eventId;
      },
      debugLabel: 'syncShift',
    );
  }

  Future<Result<void>> deleteEvent(String eventId) async {
    googleCalendarDebug('Deleting calendar event $eventId');

    final result = await _withCalendarApi(
      (api) async {
        try {
          await api.events.delete('primary', eventId);
        } on DetailedApiRequestError catch (e) {
          if (e.status == 404 || e.status == 410) {
            googleCalendarDebug('Calendar event $eventId already removed');
            return;
          }
          rethrow;
        }
      },
      debugLabel: 'deleteEvent',
    );

    return switch (result) {
      Success() => const Success(null),
      Error(:final failure) => Error(failure),
    };
  }

  /// Requests Google Calendar access and verifies the API works.
  Future<String> _primaryCalendarTimeZone(gapis.AuthClient client) async {
    if (_cachedCalendarTimeZone != null) {
      return _cachedCalendarTimeZone!;
    }

    try {
      _cachedCalendarTimeZone =
          await GoogleCalendarEventApi.fetchPrimaryTimeZone(client);
      return _cachedCalendarTimeZone!;
    } catch (e, st) {
      googleCalendarDebug(
        'Could not read primary calendar timezone; using device timezone',
        error: e,
        stackTrace: st,
      );
      return CalendarTimezone.localTimeZoneName();
    }
  }

  Future<Result<void>> connect() async {
    googleCalendarDebug('Connect requested');

    final tzResult = await _withCalendarClient<void>(
      (client) async {
        _cachedCalendarTimeZone =
            await GoogleCalendarEventApi.fetchPrimaryTimeZone(client);
      },
      debugLabel: 'connectTimezone',
    );

    if (tzResult is Error<void>) {
      googleCalendarDebug(
        'Could not cache calendar timezone during connect',
        error: tzResult.failure.message,
      );
    }

    final verify = await _withCalendarApi(
      (api) => api.events.list('primary', maxResults: 1),
      debugLabel: 'connect',
    );

    return switch (verify) {
      Success() => const Success(null),
      Error(:final failure) => Error(failure),
    };
  }
}
