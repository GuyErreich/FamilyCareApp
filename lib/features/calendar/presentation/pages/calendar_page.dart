import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_month.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_planner.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_actions.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_preferences.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_month_year_picker.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_slot_confirm_bar.dart';
import 'package:family_care_scheduler/features/unavailability/presentation/providers/unavailability_providers.dart';
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
  final _monthKey = GlobalKey<FamilyScheduleMonthState>();

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTimeUtils.dateOnly(DateTime.now());
  }

  DateTime get _weekStart => DateTimeUtils.startOfWeek(_focusedDate);

  DateTime get _monthAnchor => DateTime(_focusedDate.year, _focusedDate.month);

  DateTime _plannerStart(int daysShowed) => daysShowed == 7
      ? _weekStart
      : DateTimeUtils.dateOnly(_focusedDate);

  String _plannerLabel(int daysShowed) {
    final start = _plannerStart(daysShowed);
    if (daysShowed == 7) {
      return 'Week of ${DateTimeUtils.formatDate(start)}';
    }
    final end = start.add(Duration(days: daysShowed - 1));
    return '${DateTimeUtils.formatDate(start)} – ${DateTimeUtils.formatDate(end)}';
  }

  Future<void> _setDaysShowed(int days) async {
    if (days == ref.read(scheduleDaysShowedProvider)) return;

    final result = await updateScheduleDaysShowed(ref, days);
    if (!mounted) return;

    switch (result) {
      case Success():
        setState(() => _selection = null);
      case Error(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final daysShowed = ref.watch(scheduleDaysShowedProvider);

    ref.listen<int>(scheduleDaysShowedProvider, (previous, next) {
      if (previous == null || previous == next || _monthView) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          if (next == 7) {
            _focusedDate = DateTimeUtils.startOfWeek(_focusedDate);
          }
        });
        _jumpCalendarTo(_plannerStart(next));
      });
    });

    final plannerStart = _plannerStart(daysShowed);
    final shiftsAsync = _monthView
        ? ref.watch(monthShiftsProvider(_monthAnchor))
        : ref.watch(rangeShiftsProvider((plannerStart, daysShowed)));
    final blocksAsync = _monthView
        ? ref.watch(monthUnavailabilitiesProvider(_monthAnchor))
        : ref.watch(rangeUnavailabilitiesProvider((plannerStart, daysShowed)));
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final canManageOthers = ref.watch(canManageFamilyShiftsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return AppScaffold(
      title: 'Calendar',
      actions: [
        if (!_monthView)
          PopupMenuButton<int>(
            tooltip: 'Schedule view',
            icon: Icon(
              daysShowed == 3 ? Icons.view_day : Icons.view_week,
            ),
            initialValue: daysShowed,
            onSelected: _setDaysShowed,
            itemBuilder: (context) => ScheduleConstants.allowedDaysShowed
                .map(
                  (days) => PopupMenuItem(
                    value: days,
                    child: Text(scheduleDaysShowedLabel(days)),
                  ),
                )
                .toList(),
          ),
        IconButton(
          onPressed: () => setState(() {
            _monthView = !_monthView;
            _selection = null;
          }),
          icon: Icon(_monthView ? Icons.view_week : Icons.calendar_view_month),
          tooltip: _monthView ? 'Planner view' : 'Month view',
        ),
      ],
      body: Column(
        children: [
          _CalendarHeader(
            label: _monthView
                ? DateTimeUtils.formatMonthYear(_monthAnchor)
                : _plannerLabel(daysShowed),
            onLabelTap: () => _pickMonthYear(daysShowed),
            onPrevious: () => _stepCalendar(-1, daysShowed),
            onNext: () => _stepCalendar(1, daysShowed),
            onToday: () => _goToToday(daysShowed),
          ),
          if (!_monthView)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
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
                        key: _monthKey,
                        shifts: shifts,
                        members: members,
                        initialMonth: _monthAnchor,
                        onDayTap: (day) => context.push(
                          AppRoutes.daySchedule,
                          extra: {'day': DateTimeUtils.dateOnly(day)},
                        ),
                        onShiftTap: (shift) =>
                            context.push('/shifts/${shift.id}'),
                      )
                    : AsyncValueWidget(
                        value: blocksAsync,
                        data: (blocks) => FamilySchedulePlanner(
                          plannerKey: _plannerKey,
                          shifts: shifts,
                          unavailabilities: blocks,
                          members: members,
                          daysShowed: daysShowed,
                          initialDate: plannerStart,
                          currentUserId: user?.id,
                          enableSlotSelection: user != null,
                          onShiftTap: (shift) =>
                              context.push('/shifts/${shift.id}'),
                          onUnavailabilityTap: user == null
                              ? null
                              : (block) => showUnavailabilityActions(
                                    context,
                                    ref,
                                    block: block,
                                    currentUserId: user.id,
                                    canManageOthers: canManageOthers,
                                  ),
                          onSlotSelected: user == null
                              ? null
                              : (slot) => setState(() => _selection = slot),
                        ),
                        ),
              ),
            ),
          if (_selection != null && user != null && !_monthView)
            ScheduleSlotConfirmBar(
              selection: _selection!,
              members: members,
              currentUserId: user.id,
              canManageOthers: canManageOthers,
              onClear: () => setState(() => _selection = null),
              onConfirmShift: (assigneeId) {
                final slot = _selection!;
                setState(() => _selection = null);
                openCreateShiftForSlot(
                  context,
                  selection: slot,
                  userId: assigneeId,
                );
              },
              onConfirmUnavailable: (userId) async {
                final slot = _selection!;
                final familyId = user.familyId;
                if (familyId == null) return;

                final result = await saveUnavailabilityForSlot(
                  ref,
                  selection: slot,
                  userId: userId,
                  familyId: familyId,
                );
                if (!mounted) return;

                setState(() => _selection = null);
                switch (result) {
                  case Success():
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unavailability saved')),
                    );
                  case Error(:final failure):
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(failure.message)),
                    );
                }
              },
            ),
        ],
      ),
    );
  }

  Future<void> _pickMonthYear(int daysShowed) async {
    final initial = _monthView ? _monthAnchor : _focusedDate;
    final picked = await showScheduleMonthYearPicker(
      context,
      initial: initial,
    );
    if (picked == null || !mounted) return;

    final monthStart = DateTime(picked.year, picked.month);
    setState(() {
      _focusedDate = _monthView
          ? monthStart
          : daysShowed == 7
              ? DateTimeUtils.startOfWeek(monthStart)
              : monthStart;
      _selection = null;
    });

    _jumpCalendarTo(_monthView ? monthStart : _plannerStart(daysShowed));
  }

  void _stepCalendar(int direction, int daysShowed) {
    final target = _monthView
        ? DateTime(_focusedDate.year, _focusedDate.month + direction)
        : _focusedDate.add(Duration(days: daysShowed * direction));

    setState(() {
      _focusedDate = target;
      _selection = null;
    });

    _jumpCalendarTo(
      _monthView ? _monthAnchor : _plannerStart(daysShowed),
    );
  }

  void _goToToday(int daysShowed) {
    final today = DateTime.now();
    setState(() {
      _focusedDate = _monthView
          ? DateTime(today.year, today.month)
          : daysShowed == 7
              ? DateTimeUtils.startOfWeek(today)
              : DateTimeUtils.dateOnly(today);
      _selection = null;
    });

    _jumpCalendarTo(today);
  }

  /// Jump after layout; avoids scroll_controller assertion when combined with rebuilds.
  void _jumpCalendarTo(DateTime date) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_monthView) {
          _monthKey.currentState?.jumpToDate(date);
        } else {
          _plannerKey.currentState?.jumpToDate(date);
        }
      });
    });
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({
    required this.label,
    required this.onLabelTap,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final String label;
  final VoidCallback onLabelTap;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: 0.75),
          ),
        ),
        child: Row(
          children: [
            IconButton(onPressed: onPrevious, icon: const Icon(Icons.chevron_left)),
            Expanded(
              child: Column(
                children: [
                  InkWell(
                    onTap: onLabelTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(color: scheme.primary),
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            color: scheme.primary,
                          ),
                        ],
                      ),
                    ),
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
