import 'dart:convert';

import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_debug.dart';
import 'package:googleapis/calendar/v3.dart' show DetailedApiRequestError;
import 'package:googleapis_auth/googleapis_auth.dart' as gapis;
import 'package:http/http.dart' as http;

/// Raw Calendar API calls that preserve wall-clock [dateTime] + [timeZone].
///
/// The generated `googleapis` client always serializes event times with
/// [DateTime.toUtc], which breaks the Calendar API contract when a [timeZone]
/// is also supplied. These helpers send the JSON Google expects.
abstract final class GoogleCalendarEventApi {
  static const _calendarId = 'primary';
  static const _calendarUrl =
      'https://www.googleapis.com/calendar/v3/calendars/$_calendarId';
  static const _baseUrl = '$_calendarUrl/events';

  static Future<String> fetchPrimaryTimeZone(gapis.AuthClient client) async {
    final response = await client.get(
      Uri.parse(_calendarUrl),
      headers: _jsonHeaders,
    );
    final json = _decodeResponse(response);
    final timeZone = json['timeZone'] as String?;
    if (timeZone == null || timeZone.isEmpty) {
      throw StateError('Primary calendar did not return a timeZone.');
    }
    googleCalendarDebug('Primary calendar timezone: $timeZone');
    return timeZone;
  }

  static Future<String> insert(
    gapis.AuthClient client,
    Map<String, dynamic> body,
  ) async {
    googleCalendarDebug('Calendar insert body: ${jsonEncode(body)}');
    final response = await client.post(
      Uri.parse(_baseUrl),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    final json = _decodeResponse(response);
    final eventId = json['id'] as String?;
    if (eventId == null) {
      throw StateError('Google Calendar did not return an event id.');
    }
    return eventId;
  }

  static Future<String> update(
    gapis.AuthClient client,
    String eventId,
    Map<String, dynamic> body,
  ) async {
    googleCalendarDebug('Calendar update $eventId body: ${jsonEncode(body)}');
    final response = await client.put(
      Uri.parse('$_baseUrl/$eventId'),
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    final json = _decodeResponse(response);
    final updatedId = json['id'] as String?;
    if (updatedId == null) {
      throw StateError('Google Calendar did not return an event id.');
    }
    return updatedId;
  }

  static const _jsonHeaders = {
    'Content-Type': 'application/json; charset=utf-8',
  };

  static Map<String, dynamic> _decodeResponse(http.Response response) {
    final status = response.statusCode;
    final raw = response.body;
    if (status >= 200 && status < 300) {
      return jsonDecode(raw) as Map<String, dynamic>;
    }

    String? message;
    try {
      final error = jsonDecode(raw) as Map<String, dynamic>;
      message = (error['error'] as Map<String, dynamic>?)?['message'] as String?;
    } catch (_) {
      message = raw;
    }
    throw DetailedApiRequestError(status, message);
  }
}
