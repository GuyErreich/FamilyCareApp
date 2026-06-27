import 'package:family_care_scheduler/core/errors/failures.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_debug.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:googleapis/calendar/v3.dart' show DetailedApiRequestError;
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;

/// OAuth scope for reading and writing the user's Google Calendar.
const googleCalendarScope = calendar.CalendarApi.calendarScope;

/// GCP project number for `family-care-scheduler-dev` (from Firebase).
const googleCalendarGcpProjectNumber = '388117547421';

/// Link to enable Google Calendar API for this Firebase project.
const googleCalendarApiEnableUrl =
    'https://console.developers.google.com/apis/api/calendar-json.googleapis.com/overview?project=$googleCalendarGcpProjectNumber';

/// True when Calendar API is disabled in Google Cloud Console.
bool isGoogleCalendarApiDisabledError(Object error) {
  final message = switch (error) {
    DetailedApiRequestError(:final message) => message,
    _ => error.toString(),
  };
  final lower = (message ?? '').toLowerCase();
  return lower.contains('has not been used in project') ||
      lower.contains('it is disabled') ||
      lower.contains('calendar-json.googleapis.com');
}

/// True when [error] likely means the access token lacks calendar scope.
bool isGoogleCalendarAuthError(Object error) {
  if (isGoogleCalendarApiDisabledError(error)) {
    return false;
  }
  if (error is DetailedApiRequestError) {
    return error.status == 401 || error.status == 403;
  }
  final message = error.toString().toLowerCase();
  return message.contains('403') ||
      message.contains('401') ||
      message.contains('insufficient');
}

/// Ensures a Google account is signed in for calendar operations.
Future<GoogleSignInAccount?> ensureGoogleSignedIn(
  GoogleSignIn googleSignIn,
) async {
  return googleSignIn.currentUser ??
      await googleSignIn.signInSilently() ??
      await googleSignIn.signIn();
}

/// Refreshes tokens after the user grants new OAuth scopes.
Future<void> refreshGoogleAuthAfterScopeGrant(
  GoogleSignIn googleSignIn,
) async {
  googleCalendarDebug('Refreshing Google auth after scope grant');
  await googleSignIn.signInSilently(reAuthenticate: true);
}

/// Prompts the user to grant Google Calendar access for [googleSignIn].
///
/// Signs in with Google if needed, then requests the calendar scope.
/// Refreshes auth tokens when access is granted.
Future<bool> requestGoogleCalendarAccess(GoogleSignIn googleSignIn) async {
  try {
    googleCalendarDebug('Requesting calendar scope: $googleCalendarScope');

    final account = await ensureGoogleSignedIn(googleSignIn);
    if (account == null) {
      googleCalendarDebug('requestScopes skipped: no signed-in account');
      return false;
    }

    googleCalendarDebug('Requesting scopes for ${account.email}');
    final granted = await googleSignIn.requestScopes([googleCalendarScope]);
    googleCalendarDebug('requestScopes result: $granted');

    if (granted) {
      await refreshGoogleAuthAfterScopeGrant(googleSignIn);
    }

    return granted;
  } catch (e, st) {
    googleCalendarDebug('requestScopes threw', error: e, stackTrace: st);
    return false;
  }
}

/// Builds an authenticated Google Calendar API client using the current account.
Future<gapis.AuthClient?> buildCalendarAuthClient(
  GoogleSignIn googleSignIn,
) async {
  final account =
      googleSignIn.currentUser ?? await ensureGoogleSignedIn(googleSignIn);
  if (account == null) {
    return null;
  }

  final auth = await account.authentication;
  return googleSignIn.authenticatedClient(
    debugAuthentication: auth,
    debugScopes: [googleCalendarScope],
  );
}

/// Maps API errors to user-facing [CalendarFailure] messages.
CalendarFailure toCalendarFailure(Object error) {
  if (isGoogleCalendarApiDisabledError(error)) {
    return const CalendarFailure(
      'Google Calendar API is not enabled for this app. '
      'Ask the project owner to enable it in Google Cloud Console, '
      'wait a few minutes, then try again.',
    );
  }
  if (error is CalendarFailure) {
    return error;
  }
  if (error is DetailedApiRequestError) {
    return CalendarFailure(error.message ?? 'Google Calendar request failed.');
  }
  return CalendarFailure('Failed to add to Google Calendar: $error');
}
