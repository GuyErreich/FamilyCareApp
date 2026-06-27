import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_month.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_planner.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_actions.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_slot_confirm_bar.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/async_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  var _monthView = false;
  late DateTime _focusedDate;
  ScheduleSlotSelection? _selection;
  final _plannerKey = GlobalKey<EventsPlannerState>();
  final _monthKey = GlobalKey<EventsMonthsState>();

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTimeUtils.startOfWeek(DateTime.now());
  }

  DateTime get _weekStart => DateTimeUtils.startOfWeek(_focusedDate);

  DateTime get _monthAnchor => DateTime(_focusedDate.year, _focusedDate.month);

  @override
  Widget build(BuildContext context) {
    final shiftsAsync = _monthView
        ? ref.watch(monthShiftsProvider(_monthAnchor))
        : ref.watch(weekShiftsProvider(_weekStart));
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final user = ref.watch(authStateProvider).valueOrNull;

    return AppScaffold(
      title: 'Calendar',
      actions: [
        IconButton(
          onPressed: () => setState(() {
            _monthView = !_monthView;
            _selection = null;
          }),
          icon: Icon(_monthView ? Icons.view_week : Icons.calendar_view_month),
          tooltip: _monthView ? 'Week view' : 'Month view',
        ),
      ],
      body: Column(
        children: [
          _CalendarHeader(
            label: _monthView
                ? DateTimeUtils.formatDate(_monthAnchor)
                : 'Week of ${DateTimeUtils.formatDate(_weekStart)}',
            onPrevious: () => _stepCalendar(-1),
            onNext: () => _stepCalendar(1),
            onToday: _goToToday,
          ),
          if (!_monthView)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: shiftsAsync.when(
                data: (shifts) => ScheduleLegend(
                  members: members,
                  shifts: shifts,
                  currentUserId: user?.id,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, _) => const SizedBox.shrink(),
              ),
            ),
          Expanded(
            child: AsyncValueWidget(
              value: shiftsAsync,
              data: (shifts) => _monthView
                  ? FamilyScheduleMonth(
                      key: ValueKey(_monthAnchor),
                      monthKey: _monthKey,
                      shifts: shifts,
                      members: members,
                      initialMonth: _monthAnchor,
                      onMonthChange: (month) =>
                          setState(() => _focusedDate = month),
                      onDayTap: (day) => context.push(
                        AppRoutes.daySchedule,
                        extra: {'day': DateTimeUtils.dateOnly(day)},
                      ),
                      onShiftTap: (shift) =>
                          context.push('/shifts/${shift.id}'),
                    )
                  : FamilySchedulePlanner(
                      key: ValueKey(_weekStart),
                      plannerKey: _plannerKey,
                      shifts: shifts,
                      members: members,
                      daysShowed: 7,
                      initialDate: _weekStart,
                      currentUserId: user?.id,
                      enableSlotSelection: user != null,
                      onFirstDayChange: (firstDay) =>
                          setState(() => _focusedDate = firstDay),
                      onShiftTap: (shift) =>
                          context.push('/shifts/${shift.id}'),
                      onSlotSelected: user == null
                          ? null
                          : (slot) => setState(() => _selection = slot),
                    ),
            ),
          ),
          if (_selection != null && user != null && !_monthView)
            ScheduleSlotConfirmBar(
              selection: _selection!,
              onClear: () => setState(() => _selection = null),
              onConfirm: () {
                final slot = _selection!;
                setState(() => _selection = null);
                openCreateShiftForSlot(
                  context,
                  selection: slot,
                  userId: user.id,
                );
              },
            ),
        ],
      ),
    );
  }

  void _stepCalendar(int direction) {
    setState(() {
      _focusedDate = _monthView
          ? DateTime(_focusedDate.year, _focusedDate.month + direction)
          : _focusedDate.add(Duration(days: 7 * direction));
      _selection = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_monthView) {
        _monthKey.currentState?.jumpToDate(_monthAnchor);
      } else {
        _plannerKey.currentState?.jumpToDate(_weekStart);
      }
    });
  }

  void _goToToday() {
    setState(() {
      _focusedDate = _monthView
          ? DateTime(DateTime.now().year, DateTime.now().month)
          : DateTimeUtils.startOfWeek(DateTime.now());
      _selection = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_monthView) {
        _monthKey.currentState?.jumpToDate(DateTime.now());
      } else {
        _plannerKey.currentState?.jumpToDate(DateTime.now());
      }
    });
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.label,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Column(
                children: [
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  TextButton(onPressed: onToday, child: const Text('Today')),
                ],
              ),
            ),
            IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
          ],
        ),
      ),
    );
  }
}
