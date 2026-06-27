import 'package:flutter/foundation.dart';
import 'package:googleapis/calendar/v3.dart' show DetailedApiRequestError;

const _tag = 'GoogleCalendar';

const _googleCalendarApiEnableUrl =
    'https://console.developers.google.com/apis/api/calendar-json.googleapis.com/overview?project=388117547421';

bool _isApiDisabledError(Object error) {
  final message = switch (error) {
    DetailedApiRequestError(:final message) => message,
    _ => error.toString(),
  };
  final lower = (message ?? '').toLowerCase();
  return lower.contains('has not been used in project') ||
      lower.contains('it is disabled');
}

/// Logs Google Calendar diagnostics to the console in debug builds only.
void googleCalendarDebug(
  String message, {
  Object? error,
  StackTrace? stackTrace,
}) {
  if (!kDebugMode) return;

  final buffer = StringBuffer('[$_tag] $message');
  if (error != null) {
    buffer.write('\n  ${_formatError(error)}');
    if (error is DetailedApiRequestError && _isApiDisabledError(error)) {
      buffer.write(
        '\n  hint: Enable Google Calendar API at $_googleCalendarApiEnableUrl '
        'then wait a few minutes and retry.',
      );
    } else if (error is DetailedApiRequestError && error.status == 403) {
      buffer.write(
        '\n  hint: Enable Google Calendar API in Google Cloud Console for '
        'project family-care-scheduler-dev, and add the calendar scope to '
        'your OAuth consent screen.',
      );
    }
  }

  debugPrint(buffer.toString());
  if (stackTrace != null) {
    debugPrintStack(stackTrace: stackTrace, label: _tag);
  }
}

String _formatError(Object error) {
  if (error is DetailedApiRequestError) {
    final details = error.errors?.map((e) => e.toString()).join('; ');
    return 'error: HTTP ${error.status} ${error.message}'
        '${details != null && details.isNotEmpty ? ' ($details)' : ''}';
  }
  return 'error: $error';
}
