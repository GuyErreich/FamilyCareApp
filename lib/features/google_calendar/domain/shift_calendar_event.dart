import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';

/// Builds Google Calendar copy for a companion shift.
abstract final class ShiftCalendarEvent {
  static String summary({
    String? familyName,
    String? careRecipientName,
    String? companionName,
  }) {
    final parts = <String>['Companion shift'];
    if (familyName != null && familyName.trim().isNotEmpty) {
      parts.add(familyName.trim());
    }
    if (careRecipientName != null && careRecipientName.trim().isNotEmpty) {
      parts.add('for ${careRecipientName.trim()}');
    }
    if (companionName != null && companionName.trim().isNotEmpty) {
      parts.add('with ${companionName.trim()}');
    }
    return parts.join(' · ');
  }

  static String description({
    required Shift shift,
    String? familyName,
    String? careRecipientName,
    String? companionName,
  }) {
    final lines = <String>[
      DateTimeUtils.formatTimeRange(shift.startDateTime, shift.endDateTime),
      DateTimeUtils.formatDate(shift.date),
    ];

    if (familyName != null && familyName.trim().isNotEmpty) {
      lines.add('Family: ${familyName.trim()}');
    }
    if (careRecipientName != null && careRecipientName.trim().isNotEmpty) {
      lines.add('Care recipient: ${careRecipientName.trim()}');
    }
    if (companionName != null && companionName.trim().isNotEmpty) {
      lines.add('Companion: ${companionName.trim()}');
    }

    final notes = shift.notes?.trim();
    if (notes != null && notes.isNotEmpty) {
      lines.add('');
      lines.add(notes);
    }

    return lines.join('\n');
  }
}
