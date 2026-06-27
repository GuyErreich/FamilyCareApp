import 'package:family_care_scheduler/core/constants/app_constants.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_service.dart';
import 'package:family_care_scheduler/features/notifications/domain/local_notification_service.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:family_care_scheduler/features/shifts/domain/usecases/validate_shift_use_case.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

class CreateShiftPage extends ConsumerStatefulWidget {
  const CreateShiftPage({
    this.shiftId,
    this.initialDate,
    this.initialUserId,
    super.key,
  });

  final String? shiftId;
  final DateTime? initialDate;
  final String? initialUserId;

  @override
  ConsumerState<CreateShiftPage> createState() => _CreateShiftPageState();
}

class _CreateShiftPageState extends ConsumerState<CreateShiftPage> {
  final _notesController = TextEditingController();
  late DateTime _date;
  late TimeOfDay _startTime;
  var _durationMinutes = 120;
  String? _assignedUserId;
  var _addToCalendar = false;
  var _isLoading = false;
  String? _error;
  Shift? _existing;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _date = widget.initialDate ?? now;
    _startTime = TimeOfDay(hour: now.hour, minute: now.minute);
    _assignedUserId = widget.initialUserId;
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
        _startTime = shift.startTime;
        _durationMinutes = shift.durationMinutes;
        _assignedUserId = shift.assignedUserId;
        _notesController.text = shift.notes ?? '';
        _addToCalendar = shift.calendarEventId != null;
      }),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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
      calendarEventId: _existing?.calendarEventId,
      status: _existing?.status ?? ShiftStatus.scheduled,
      createdAt: _existing?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> _save() async {
    if (_assignedUserId == null) {
      setState(() => _error = 'Select a family member.');
      return;
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
    if (_addToCalendar) {
      final calendar = ref.read(googleCalendarServiceProvider);
      final eventId = await calendar.syncShift(shiftToSave);
      shiftToSave = shiftToSave.copyWith(calendarEventId: eventId);
    }

    final result = _existing == null
        ? await ref.read(shiftRepositoryProvider).createShift(shiftToSave)
        : await ref.read(shiftRepositoryProvider).updateShift(shiftToSave);

    if (!mounted) return;
    result.when(
      success: (saved) async {
        await ref
            .read(localNotificationServiceProvider)
            .scheduleShiftReminders(saved);
        if (mounted) context.pop();
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
                if (picked != null) setState(() => _date = picked);
              },
            ),
            ListTile(
              title: const Text('Start time'),
              subtitle: Text(DateTimeUtils.formatTimeOfDay(_startTime)),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
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
                if (picked != null) setState(() => _startTime = picked);
              },
            ),
            const SizedBox(height: 8),
            Text('Duration', style: Theme.of(context).textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: [60, 120, 180, 240].map((minutes) {
                return ChoiceChip(
                  label: Text(DateTimeUtils.formatDuration(minutes)),
                  selected: _durationMinutes == minutes,
                  onSelected: (_) => setState(() => _durationMinutes = minutes),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _assignedUserId,
              decoration: const InputDecoration(labelText: 'Companion'),
              items: members
                  .map(
                    (m) => DropdownMenuItem(
                      value: m.userId ?? m.id,
                      child: Text(m.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _assignedUserId = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            SwitchListTile(
              title: const Text('Add to Google Calendar'),
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
