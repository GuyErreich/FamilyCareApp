import 'package:family_care_scheduler/core/constants/app_constants.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_access.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_debug.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_service.dart';
import 'package:family_care_scheduler/features/notifications/domain/local_notification_service.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:family_care_scheduler/features/shifts/domain/usecases/validate_shift_use_case.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/primary_button.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class CreateShiftPage extends ConsumerStatefulWidget {
  const CreateShiftPage({
    this.shiftId,
    this.initialDate,
    this.initialUserId,
    this.initialStartHour,
    this.initialStartMinute,
    this.initialDurationMinutes,
    super.key,
  });

  final String? shiftId;
  final DateTime? initialDate;
  final String? initialUserId;
  final int? initialStartHour;
  final int? initialStartMinute;
  final int? initialDurationMinutes;

  @override
  ConsumerState<CreateShiftPage> createState() => _CreateShiftPageState();
}

class _CreateShiftPageState extends ConsumerState<CreateShiftPage> {
  final _notesController = TextEditingController();
  late DateTime _date;
  late TimeOfDay _startTime;
  var _durationMinutes = ScheduleConstants.defaultDurationMinutes;
  String? _assignedUserId;
  var _addToCalendar = true;
  var _isLoading = false;
  String? _error;
  Shift? _existing;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = widget.initialDate ?? now;
    if (widget.initialStartHour != null) {
      _startTime = _snapTimeOfDay(
        TimeOfDay(
          hour: widget.initialStartHour!,
          minute: widget.initialStartMinute ?? 0,
        ),
      );
    } else {
      _startTime = _snapTimeOfDay(TimeOfDay(hour: now.hour, minute: now.minute));
    }
    _durationMinutes = _clampDuration(
      widget.initialDurationMinutes ?? ScheduleConstants.defaultDurationMinutes,
    );
    _assignedUserId = widget.initialUserId ??
        ref.read(authStateProvider).valueOrNull?.id;
    if (widget.shiftId != null) {
      _loadShift();
    }
  }

  Future<void> _loadShift() async {
    final result =
        await ref.read(shiftRepositoryProvider).getShift(widget.shiftId!);
    if (!mounted) return;
    result.when(
      success: (shift) => setState(() {
        _existing = shift;
        _date = shift.date;
        _startTime = _snapTimeOfDay(shift.startTime);
        _durationMinutes = _clampDuration(shift.durationMinutes);
        _assignedUserId = shift.assignedUserId;
        _notesController.text = shift.notes ?? '';
        _addToCalendar = true;
      }),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  DateTime get _startDateTime =>
      DateTimeUtils.combineDateAndTime(_date, _startTime);

  DateTime get _endDateTime =>
      _startDateTime.add(Duration(minutes: _durationMinutes));

  TimeOfDay get _endTime =>
      TimeOfDay(hour: _endDateTime.hour, minute: _endDateTime.minute);

  int get _maxDurationMinutes {
    final endOfDay = DateTime(_date.year, _date.month, _date.day + 1);
    final remaining = endOfDay.difference(_startDateTime).inMinutes;
    final snapped = (remaining / ScheduleConstants.snapMinutes).floor() *
        ScheduleConstants.snapMinutes;
    return snapped.clamp(
      ScheduleConstants.snapMinutes,
      remaining,
    );
  }

  TimeOfDay _snapTimeOfDay(TimeOfDay time) {
    final total = time.hour * 60 + time.minute;
    final snapped = (total / ScheduleConstants.snapMinutes).round() *
        ScheduleConstants.snapMinutes;
    final normalized = snapped % (24 * 60);
    return TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
  }

  int _clampDuration(int minutes) {
    final snapped = (minutes / ScheduleConstants.snapMinutes).round() *
        ScheduleConstants.snapMinutes;
    return snapped.clamp(ScheduleConstants.snapMinutes, _maxDurationMinutes);
  }

  void _adjustDuration(int deltaMinutes) {
    setState(() {
      _durationMinutes = _clampDuration(_durationMinutes + deltaMinutes);
      _error = null;
    });
  }

  void _setDurationFromEnd(TimeOfDay end) {
    final endDateTime = DateTimeUtils.combineDateAndTime(_date, end);
    if (!endDateTime.isAfter(_startDateTime)) {
      setState(() => _error = 'End time must be after start time.');
      return;
    }
    final minutes = endDateTime.difference(_startDateTime).inMinutes;
    setState(() {
      _durationMinutes = _clampDuration(minutes);
      _error = null;
    });
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: true,
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _startTime = _snapTimeOfDay(picked);
      _durationMinutes = _clampDuration(_durationMinutes);
      _error = null;
    });
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          alwaysUse24HourFormat: true,
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    _setDurationFromEnd(_snapTimeOfDay(picked));
  }

  Shift _buildShift() {
    final now = DateTime.now();
    final start = DateTimeUtils.combineDateAndTime(_date, _startTime);
    final end = start.add(Duration(minutes: _durationMinutes));
    final user = ref.read(authStateProvider).valueOrNull!;

    return Shift(
      id: _existing?.id ?? const Uuid().v4(),
      familyId: user.familyId!,
      assignedUserId: _assignedUserId!,
      date: DateTimeUtils.dateOnly(_date),
      startTime: _startTime,
      durationMinutes: _durationMinutes,
      endTime: end,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      reminderOffsets: AppConstants.defaultReminderOffsets,
      calendarEventId:
          _addToCalendar ? _existing?.calendarEventId : null,
      status: _existing?.status ?? ShiftStatus.scheduled,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<({
    String? familyName,
    String? careRecipientName,
    String? companionName,
  })> _calendarSyncContext(Shift shift) async {
    String? companionName;
    final members = ref.read(familyMembersProvider).valueOrNull;
    if (members != null) {
      for (final member in members) {
        if (member.id == shift.assignedUserId) {
          companionName = member.name;
          break;
        }
      }
    }

    String? familyName;
    String? careRecipientName;
    final familyResult =
        await ref.read(familyRepositoryProvider).getFamily(shift.familyId);
    final family = switch (familyResult) {
      Success(:final data) => data,
      Error() => null,
    };
    if (family != null) {
      familyName = family.name;
      careRecipientName = family.grandpaName;
    }

    return (
      familyName: familyName,
      careRecipientName: careRecipientName,
      companionName: companionName,
    );
  }

  Future<void> _save() async {
    if (_assignedUserId == null) {
      setState(() => _error = 'Select a family member.');
      return;
    }

    final canManageOthers = ref.read(canManageFamilyShiftsProvider);
    final user = ref.read(authStateProvider).valueOrNull;
    final members = ref.read(familyMembersProvider).valueOrNull ?? [];
    if (!canManageOthers && user != null) {
      final currentMember = FamilyMemberRole.memberForUser(user.id, members);
      final allowedIds = {
        user.id,
        if (currentMember != null) currentMember.id,
      };
      if (!allowedIds.contains(_assignedUserId)) {
        setState(() => _error = 'You can only schedule shifts for yourself.');
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final shift = _buildShift();
    final validation = await ValidateShiftUseCase(
      ref.read(shiftRepositoryProvider),
    ).call(shift);

    if (validation is Error<void>) {
      setState(() {
        _error = validation.failure.message;
        _isLoading = false;
      });
      return;
    }

    var shiftToSave = shift;
    String? calendarWarning;
    String? syncedAccountEmail;

    if (!_addToCalendar) {
      final existingEventId = _existing?.calendarEventId;
      if (existingEventId != null) {
        final deleteResult = await ref
            .read(googleCalendarServiceProvider)
            .deleteEvent(existingEventId);
        switch (deleteResult) {
          case Success():
            shiftToSave = shiftToSave.copyWith(calendarEventId: null);
            syncedAccountEmail = await ref
                .read(googleCalendarServiceProvider)
                .calendarAccountEmail();
          case Error(:final failure):
            calendarWarning =
                'Could not remove from Google Calendar: ${failure.message}';
            shiftToSave = shiftToSave.copyWith(calendarEventId: existingEventId);
            googleCalendarDebug(
              'Remove shift from calendar failed',
              error: failure.message,
            );
        }
      } else {
        shiftToSave = shiftToSave.copyWith(calendarEventId: null);
      }
    } else {
      try {
        final calendarService = ref.read(googleCalendarServiceProvider);
        final calendarContext = await _calendarSyncContext(shiftToSave);
        final syncResult = await calendarService.syncShift(
          shiftToSave,
          familyName: calendarContext.familyName,
          careRecipientName: calendarContext.careRecipientName,
          companionName: calendarContext.companionName,
        );
        switch (syncResult) {
          case Success(:final data):
            shiftToSave = shiftToSave.copyWith(calendarEventId: data);
            syncedAccountEmail = await calendarService.calendarAccountEmail();
            final user = ref.read(authStateProvider).valueOrNull;
            if (user != null && !user.googleCalendarConnected) {
              await ref.read(authRepositoryProvider).updateUser(
                    user.copyWith(googleCalendarConnected: true),
                  );
            }
          case Error(:final failure):
            calendarWarning = failure.message;
            googleCalendarDebug(
              'Create shift calendar sync failed',
              error: failure.message,
            );
            if (_existing?.calendarEventId == null) {
              shiftToSave = shiftToSave.copyWith(calendarEventId: null);
            }
        }
      } catch (e, st) {
        calendarWarning = toCalendarFailure(e).message;
        googleCalendarDebug(
          'Create shift calendar sync threw',
          error: e,
          stackTrace: st,
        );
        if (_existing?.calendarEventId == null) {
          shiftToSave = shiftToSave.copyWith(calendarEventId: null);
        }
      }
    }

    final result = _existing == null
        ? await ref.read(shiftRepositoryProvider).createShift(shiftToSave)
        : await ref.read(shiftRepositoryProvider).updateShift(shiftToSave);

    if (!mounted) return;
    result.when(
      success: (saved) async {
        try {
          await ref
              .read(localNotificationServiceProvider)
              .scheduleShiftReminders(saved);
        } catch (_) {
          // Shift was saved; reminders are best-effort.
        }
        if (!mounted) return;
        if (calendarWarning != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(calendarWarning)),
          );
        } else if (syncedAccountEmail != null) {
          final removed = _existing?.calendarEventId != null && !_addToCalendar;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                removed
                    ? 'Removed from Google Calendar ($syncedAccountEmail).'
                    : 'Added to Google Calendar ($syncedAccountEmail). '
                        'Open that account in your Calendar app if you do not see it.',
              ),
            ),
          );
        }
        context.pop(saved);
      },
      failure: (f) => setState(() {
        _error = f.message;
        _isLoading = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final canManageOthers = ref.watch(canManageFamilyShiftsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final assigneeId = _assignedUserId ?? user?.id;

    return AppScaffold(
      title: _existing == null ? 'Create shift' : 'Edit shift',
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: const Text('Date'),
              subtitle: Text(DateTimeUtils.formatDate(_date)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  initialDate: _date,
                );
                if (picked != null) {
                  setState(() {
                    _date = picked;
                    _durationMinutes = _clampDuration(_durationMinutes);
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            _ShiftScheduleSection(
              startTime: _startTime,
              endTime: _endTime,
              timeRangeLabel: DateTimeUtils.formatTimeRange(
                _startDateTime,
                _endDateTime,
              ),
              durationLabel: DateTimeUtils.formatDuration(_durationMinutes),
              canDecrease:
                  _durationMinutes > ScheduleConstants.snapMinutes,
              canIncrease: _durationMinutes < _maxDurationMinutes,
              onPickStart: _pickStartTime,
              onPickEnd: _pickEndTime,
              onDecrease: () => _adjustDuration(-ScheduleConstants.snapMinutes),
              onIncrease: () => _adjustDuration(ScheduleConstants.snapMinutes),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: assigneeId,
              decoration: const InputDecoration(labelText: 'Companion'),
              items: members
                  .map(
                    (m) => DropdownMenuItem(
                      value: FamilyMemberRole.assignableId(m),
                      child: Text(m.name),
                    ),
                  )
                  .toList(),
              onChanged: canManageOthers
                  ? (value) => setState(() => _assignedUserId = value)
                  : null,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            SwitchListTile(
              title: Text(
                _existing?.calendarEventId != null
                    ? 'Google Calendar sync'
                    : 'Add to Google Calendar',
              ),
              subtitle: Text(
                !_addToCalendar && _existing?.calendarEventId != null
                    ? 'Save to remove this shift from your calendar'
                    : 'Synced to your Google Calendar when you save',
              ),
              value: _addToCalendar,
              onChanged: (v) => setState(() => _addToCalendar = v),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(
              label: _existing == null ? 'Create shift' : 'Save changes',
              isLoading: _isLoading,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}

class _ShiftScheduleSection extends StatelessWidget {
  const _ShiftScheduleSection({
    required this.startTime,
    required this.endTime,
    required this.timeRangeLabel,
    required this.durationLabel,
    required this.canDecrease,
    required this.canIncrease,
    required this.onPickStart,
    required this.onPickEnd,
    required this.onDecrease,
    required this.onIncrease,
  });

  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String timeRangeLabel;
  final String durationLabel;
  final bool canDecrease;
  final bool canIncrease;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Schedule', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Text(
              timeRangeLabel,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '$durationLabel duration',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickStart,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Start',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateTimeUtils.formatTimeOfDay(startTime),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onPickEnd,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'End',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          DateTimeUtils.formatTimeOfDay(endTime),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: canDecrease ? onDecrease : null,
                  icon: const Icon(Icons.remove),
                  tooltip: '15 minutes shorter',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    durationLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: canIncrease ? onIncrease : null,
                  icon: const Icon(Icons.add),
                  tooltip: '15 minutes longer',
                ),
              ],
            ),
            Text(
              'Adjust in ${ScheduleConstants.snapMinutes}-minute steps',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
