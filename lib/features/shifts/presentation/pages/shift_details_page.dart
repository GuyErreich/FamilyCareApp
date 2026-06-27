import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/google_sign_in_provider.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';
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

  Future<void> _removeShift() async {
    final shift = _shift!;
    if (shift.calendarEventId != null) {
      final deleteResult = await ref
          .read(googleCalendarServiceProvider)
          .deleteEvent(shift.calendarEventId!);
      if (!mounted) return;
      if (deleteResult is Error<void>) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Shift removed, but calendar event could not be deleted: '
              '${deleteResult.failure.message}',
            ),
          ),
        );
      }
    }
    await ref.read(localNotificationServiceProvider).cancelShiftReminders(shift.id);
    await ref.read(shiftRepositoryProvider).deleteShift(shift.id);
    if (mounted) context.pop();
  }

  Future<void> _delete() => _removeShift();

  Future<void> _cantMakeIt() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Can\'t make this shift?'),
        content: const Text(
          'Your shift will be opened for coverage. The family backup '
          'list will be notified so someone else can step in. Any linked '
          'Google Calendar event will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep shift'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Release shift'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await _removeShift();
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
    final user = ref.watch(authStateProvider).valueOrNull;
    final canManage = FamilyMemberRole.canManageShift(
      shift: shift,
      userId: user?.id,
      members: members,
    );
    final isAssignee = FamilyMemberRole.isShiftAssignedToUser(
      shift: shift,
      userId: user?.id,
      members: members,
    );
    final canRelease = isAssignee &&
        shift.status == ShiftStatus.scheduled &&
        !shift.isInPast;
    final calendarEmail = ref.watch(googleSignInProvider).currentUser?.email;
    final member = members
        .where(
          (m) =>
              m.userId == shift.assignedUserId ||
              m.id == shift.assignedUserId,
        )
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
              value: DateTimeUtils.formatTimeRange(
                shift.startDateTime,
                shift.endDateTime,
              ),
            ),
            _DetailRow(
              label: 'Duration',
              value: DateTimeUtils.formatDuration(shift.durationMinutes),
            ),
            if (shift.notes != null)
              _DetailRow(label: 'Notes', value: shift.notes!),
            _DetailRow(
              label: 'Calendar',
              value: shift.calendarEventId != null
                  ? calendarEmail == null
                      ? 'Synced'
                      : 'Synced to $calendarEmail'
                  : 'Not synced',
            ),
            _DetailRow(label: 'Status', value: shift.status.name),
            const Spacer(),
            if (canRelease) ...[
              PrimaryButton(
                label: 'Can\'t make it',
                icon: Icons.event_busy,
                onPressed: _cantMakeIt,
              ),
              const SizedBox(height: 12),
            ],
            if (canManage && shift.status == ShiftStatus.scheduled) ...[
              PrimaryButton(
                label: 'Mark completed',
                icon: Icons.check_circle,
                onPressed: _markCompleted,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () async {
                  final updated =
                      await context.push<Shift>('/shifts/${shift.id}/edit');
                  if (!mounted) return;
                  if (updated != null) {
                    setState(() => _shift = updated);
                  }
                },
                child: const Text('Edit'),
              ),
              const SizedBox(height: 12),
            ],
            if (canManage)
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
