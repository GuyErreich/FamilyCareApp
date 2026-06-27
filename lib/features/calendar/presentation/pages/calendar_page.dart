import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/async_value_widget.dart';
import 'package:family_care_scheduler/shared/widgets/member_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  var _monthView = false;
  late DateTime _focusedWeek;

  @override
  void initState() {
    super.initState();
    _focusedWeek = DateTimeUtils.startOfWeek(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final shiftsAsync = ref.watch(weekShiftsProvider(_focusedWeek));
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];

    return AppScaffold(
      title: 'Calendar',
      actions: [
        IconButton(
          onPressed: () => setState(() => _monthView = !_monthView),
          icon: Icon(_monthView ? Icons.view_week : Icons.calendar_view_month),
        ),
      ],
      body: Column(
        children: [
          _CalendarHeader(
            label: _monthView
                ? DateTimeUtils.formatDate(_focusedWeek)
                : 'Week of ${DateTimeUtils.formatDate(_focusedWeek)}',
            onPrevious: () => setState(() {
              _focusedWeek = _monthView
                  ? DateTime(_focusedWeek.year, _focusedWeek.month - 1)
                  : _focusedWeek.subtract(const Duration(days: 7));
            }),
            onNext: () => setState(() {
              _focusedWeek = _monthView
                  ? DateTime(_focusedWeek.year, _focusedWeek.month + 1)
                  : _focusedWeek.add(const Duration(days: 7));
            }),
          ),
          Expanded(
            child: AsyncValueWidget(
              value: shiftsAsync,
              data: (shifts) => _monthView
                  ? _MonthGrid(
                      focused: _focusedWeek,
                      shifts: shifts,
                      members: members,
                      onDayTap: (day) => _openDay(day, shifts, members),
                    )
                  : _WeekView(
                      weekStart: _focusedWeek,
                      shifts: shifts,
                      members: members,
                      onDayTap: (day) => _openDay(day, shifts, members),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _openDay(DateTime day, List<Shift> shifts, List<FamilyMember> members) {
    final dayShifts = shifts.where((s) => _sameDay(s.date, day)).toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _DayShiftSheet(
        day: day,
        shifts: dayShifts,
        members: members,
        onCreate: () {
          Navigator.pop(context);
          context.push(AppRoutes.createShift, extra: {'date': day});
        },
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
          Expanded(child: Text(label, textAlign: TextAlign.center)),
          IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
        ],
      ),
    );
  }
}

class _WeekView extends StatelessWidget {
  const _WeekView({
    required this.weekStart,
    required this.shifts,
    required this.members,
    required this.onDayTap,
  });

  final DateTime weekStart;
  final List<Shift> shifts;
  final List<FamilyMember> members;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (context, index) {
        final day = weekStart.add(Duration(days: index));
        final dayShifts = shifts.where((s) => _sameDay(s.date, day)).toList();
        return Card(
          child: ListTile(
            title: Text(DateTimeUtils.formatDate(day)),
            subtitle: Text('${dayShifts.length} shift(s)'),
            trailing: dayShifts.isNotEmpty
                ? MemberAvatar(
                    member: members.firstWhere(
                      (m) => m.userId == dayShifts.first.assignedUserId,
                      orElse: () => members.first,
                    ),
                    radius: 16,
                  )
                : null,
            onTap: () => onDayTap(day),
          ),
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.focused,
    required this.shifts,
    required this.members,
    required this.onDayTap,
  });

  final DateTime focused;
  final List<Shift> shifts;
  final List<FamilyMember> members;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(focused.year, focused.month + 1, 0).day;

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: daysInMonth,
      itemBuilder: (context, index) {
        final day = DateTime(focused.year, focused.month, index + 1);
        final dayShifts = shifts.where((s) => _sameDay(s.date, day)).toList();
        final color = dayShifts.isNotEmpty
            ? _colorFromHex(
                members
                        .where((m) => m.userId == dayShifts.first.assignedUserId)
                        .map((m) => m.colorHex)
                        .firstOrNull ??
                    '#4A6741',
              )
            : Theme.of(context).colorScheme.surfaceContainerHighest;

        return InkWell(
          onTap: () => onDayTap(day),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            alignment: Alignment.center,
            child: Text('${day.day}'),
          ),
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Color _colorFromHex(String hex) {
    final value = int.parse(hex.replaceFirst('#', ''), radix: 16);
    return Color(0xFF000000 | value);
  }
}

class _DayShiftSheet extends StatelessWidget {
  const _DayShiftSheet({
    required this.day,
    required this.shifts,
    required this.members,
    required this.onCreate,
  });

  final DateTime day;
  final List<Shift> shifts;
  final List<FamilyMember> members;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DateTimeUtils.formatDate(day),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (shifts.isEmpty)
              const Text('No shifts scheduled')
            else
              ...shifts.map((shift) {
                final member = members
                    .where((m) => m.userId == shift.assignedUserId)
                    .firstOrNull;
                return ListTile(
                  leading: member != null ? MemberAvatar(member: member) : null,
                  title: Text(member?.name ?? 'Companion'),
                  subtitle: Text(DateTimeUtils.formatTime(shift.startDateTime)),
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/shifts/${shift.id}');
                  },
                );
              }),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Add shift'),
            ),
          ],
        ),
      ),
    );
  }
}
