import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/dashboard/domain/usecases/get_today_schedule_use_case.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/domain/family_member_role.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/shared/widgets/app_card.dart';
import 'package:flutter/material.dart';

/// Read-only list of today's shifts for the Today tab.
class TodayShiftsView extends StatelessWidget {
  const TodayShiftsView({
    required this.schedule,
    required this.members,
    required this.onShiftTap,
    this.onOpenOverview,
    super.key,
  });

  final TodaySchedule schedule;
  final List<FamilyMember> members;
  final ValueChanged<Shift> onShiftTap;
  final VoidCallback? onOpenOverview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasShifts = schedule.current != null ||
        schedule.upcoming.isNotEmpty ||
        schedule.earlier.isNotEmpty;

    if (!hasShifts) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (schedule.hasMissingCoverage)
            _CoverageGapCard(onOpenOverview: onOpenOverview),
          const SizedBox(height: 24),
          Icon(
            Icons.event_available_outlined,
            size: 48,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No shifts today',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Open Plan to schedule coverage.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (schedule.hasMissingCoverage)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CoverageGapCard(onOpenOverview: onOpenOverview),
          ),
        if (schedule.current != null) ...[
          _SectionHeader(label: 'Happening now'),
          _ShiftCard(
            shift: schedule.current!,
            member: _memberFor(schedule.current!, members),
            emphasized: true,
            onTap: () => onShiftTap(schedule.current!),
          ),
          const SizedBox(height: 16),
        ],
        if (schedule.upcoming.isNotEmpty) ...[
          _SectionHeader(label: 'Upcoming'),
          for (final shift in schedule.upcoming) ...[
            _ShiftCard(
              shift: shift,
              member: _memberFor(shift, members),
              onTap: () => onShiftTap(shift),
            ),
            const SizedBox(height: 8),
          ],
        ],
        if (schedule.earlier.isNotEmpty) ...[
          const SizedBox(height: 8),
          _SectionHeader(label: 'Earlier today'),
          for (final shift in schedule.earlier) ...[
            _ShiftCard(
              shift: shift,
              member: _memberFor(shift, members),
              muted: true,
              onTap: () => onShiftTap(shift),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ],
    );
  }

  FamilyMember? _memberFor(Shift shift, List<FamilyMember> members) {
    for (final member in members) {
      final assignableId = FamilyMemberRole.assignableId(member);
      if (shift.assignedUserId == assignableId) {
        return member;
      }
    }
    return null;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _CoverageGapCard extends StatelessWidget {
  const _CoverageGapCard({this.onOpenOverview});

  final VoidCallback? onOpenOverview;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppCard(
      color: scheme.errorContainer,
      onTap: onOpenOverview,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: ListTile(
        leading: Icon(
          Icons.warning_amber_rounded,
          color: scheme.onErrorContainer,
        ),
        title: const Text('Gaps in today\'s coverage'),
        subtitle: const Text('Open Plan to schedule a shift.'),
        trailing: onOpenOverview == null
            ? null
            : const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({
    required this.shift,
    required this.member,
    required this.onTap,
    this.emphasized = false,
    this.muted = false,
  });

  final Shift shift;
  final FamilyMember? member;
  final VoidCallback onTap;
  final bool emphasized;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = _parseColor(member?.colorHex ?? '#4A6741');
    final alpha = muted ? 0.45 : emphasized ? 1.0 : 0.88;

    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: alpha),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          member?.name ?? 'Companion',
          style: TextStyle(
            fontWeight: emphasized ? FontWeight.w700 : FontWeight.w600,
            color: muted
                ? scheme.onSurface.withValues(alpha: 0.55)
                : scheme.onSurface,
          ),
        ),
        subtitle: Text(
          DateTimeUtils.formatTimeRange(shift.startDateTime, shift.endDateTime),
          style: TextStyle(
            color: muted
                ? scheme.onSurfaceVariant.withValues(alpha: 0.7)
                : scheme.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: scheme.onSurfaceVariant.withValues(alpha: muted ? 0.5 : 1),
        ),
      ),
    );
  }

  Color _parseColor(String hex) {
    final normalized = hex.replaceFirst('#', '');
    if (normalized.length == 6) {
      return Color(int.parse('FF$normalized', radix: 16));
    }
    return const Color(0xFF4A6741);
  }
}
