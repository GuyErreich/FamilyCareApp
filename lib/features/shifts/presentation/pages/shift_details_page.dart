import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_service.dart';
import 'package:family_care_scheduler/features/notifications/domain/local_notification_service.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/member_avatar.dart';
import 'package:family_care_scheduler/shared/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ShiftDetailsPage extends ConsumerStatefulWidget {
  const ShiftDetailsPage({required this.shiftId, super.key});

  final String shiftId;

  @override
  ConsumerState<ShiftDetailsPage> createState() => _ShiftDetailsPageState();
}

class _ShiftDetailsPageState extends ConsumerState<ShiftDetailsPage> {
  Shift? _shift;
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await ref.read(shiftRepositoryProvider).getShift(widget.shiftId);
    if (!mounted) return;
    result.when(
      success: (shift) => setState(() {
        _shift = shift;
        _isLoading = false;
      }),
      failure: (f) => setState(() {
        _error = f.message;
        _isLoading = false;
      }),
    );
  }

  Future<void> _markCompleted() async {
    final shift = _shift!.copyWith(
      status: ShiftStatus.completed,
      updatedAt: DateTime.now(),
    );
    await ref.read(shiftRepositoryProvider).updateShift(shift);
    await _load();
  }

  Future<void> _delete() async {
    final shift = _shift!;
    if (shift.calendarEventId != null) {
      await ref.read(googleCalendarServiceProvider).deleteEvent(shift.calendarEventId!);
    }
    await ref.read(localNotificationServiceProvider).cancelShiftReminders(shift.id);
    await ref.read(shiftRepositoryProvider).deleteShift(shift.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(
        title: 'Shift',
        showBackButton: true,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _shift == null) {
      return AppScaffold(
        title: 'Shift',
        showBackButton: true,
        body: Center(child: Text(_error ?? 'Shift not found')),
      );
    }

    final shift = _shift!;
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final member = members
        .where((m) => m.userId == shift.assignedUserId)
        .firstOrNull;

    return AppScaffold(
      title: 'Shift details',
      showBackButton: true,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (member != null) ListTile(
              leading: MemberAvatar(member: member),
              title: Text(member.name),
              subtitle: const Text('Companion'),
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: 'Date',
              value: DateTimeUtils.formatDate(shift.date),
            ),
            _DetailRow(
              label: 'Time',
              value: DateTimeUtils.formatTime(shift.startDateTime),
            ),
            _DetailRow(
              label: 'Duration',
              value: DateTimeUtils.formatDuration(shift.durationMinutes),
            ),
            if (shift.notes != null)
              _DetailRow(label: 'Notes', value: shift.notes!),
            _DetailRow(
              label: 'Calendar',
              value: shift.calendarEventId != null ? 'Synced' : 'Not synced',
            ),
            _DetailRow(label: 'Status', value: shift.status.name),
            const Spacer(),
            if (shift.status == ShiftStatus.scheduled) ...[
              PrimaryButton(
                label: 'Mark completed',
                icon: Icons.check_circle,
                onPressed: _markCompleted,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/shifts/${shift.id}/edit'),
                child: const Text('Edit'),
              ),
              const SizedBox(height: 12),
            ],
            TextButton(
              onPressed: _delete,
              child: Text(
                'Delete shift',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: Theme.of(context).textTheme.labelLarge),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
