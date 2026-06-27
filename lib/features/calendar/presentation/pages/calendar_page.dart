import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/core/theme/app_motion.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_month.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_planner.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner/schedule_planner_view.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_actions.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_toolbar.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_preferences.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_month_year_picker.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_slot_confirm_bar.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode_sheet.dart';
import 'package:family_care_scheduler/features/unavailability/presentation/providers/unavailability_providers.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/async_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  var _monthView = false;
  late DateTime _focusedDate;
  ScheduleSlotSelection? _selection;
  final _plannerKey = GlobalKey<SchedulePlannerViewState>();
  final _monthKey = GlobalKey<FamilyScheduleMonthState>();

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTimeUtils.dateOnly(DateTime.now());
  }

  ScheduleViewMode _viewModeFor(int daysShowed) {
    if (_monthView) return ScheduleViewMode.month;
    return daysShowed == 7 ? ScheduleViewMode.week : ScheduleViewMode.threeDay;
  }

  DateTime get _weekStart => DateTimeUtils.startOfWeek(_focusedDate);

  DateTime get _monthAnchor => DateTime(_focusedDate.year, _focusedDate.month);

  DateTime _plannerStart(int daysShowed) => daysShowed == 7
      ? _weekStart
      : DateTimeUtils.dateOnly(_focusedDate);

  String _toolbarLabel(int daysShowed) {
    if (_monthView) return DateTimeUtils.formatMonthYear(_monthAnchor);
    final start = _plannerStart(daysShowed);
    if (daysShowed == 7) {
      return 'Week of ${DateTimeUtils.formatDate(start)}';
    }
    final end = start.add(Duration(days: daysShowed - 1));
    return '${DateTimeUtils.formatDate(start)} – ${DateTimeUtils.formatDate(end)}';
  }

  Future<void> _setViewMode(ScheduleViewMode mode) async {
    HapticFeedback.selectionClick();

    switch (mode) {
      case ScheduleViewMode.month:
        setState(() {
          _monthView = true;
          _selection = null;
        });
      case ScheduleViewMode.threeDay:
        if (_monthView) {
          setState(() {
            _monthView = false;
            _selection = null;
          });
        }
        await _setDaysShowed(3);
      case ScheduleViewMode.week:
        if (_monthView) {
          setState(() {
            _monthView = false;
            _selection = null;
          });
        }
        await _setDaysShowed(7);
    }
  }

  Future<void> _cycleViewMode(int daysShowed) async {
    await _setViewMode(_viewModeFor(daysShowed).next);
  }

  Future<void> _openViewModeSheet(int daysShowed) async {
    final picked = await showScheduleViewModeSheet(
      context,
      current: _viewModeFor(daysShowed),
    );
    if (picked == null || !mounted) return;
    await _setViewMode(picked);
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
      body: Column(
        children: [
          ScheduleCalendarToolbar(
            label: _toolbarLabel(daysShowed),
            viewMode: _viewModeFor(daysShowed),
            onPrevious: () => _stepCalendar(-1, daysShowed),
            onNext: () => _stepCalendar(1, daysShowed),
            onToday: () => _goToToday(daysShowed),
            onLabelTap: () => _pickMonthYear(daysShowed),
            onViewModeTap: () => _cycleViewMode(daysShowed),
            onViewModeLongPress: () => _openViewModeSheet(daysShowed),
          ),
          if (!_monthView)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                final velocity = details.primaryVelocity ?? 0;
                if (velocity.abs() < 200) return;
                HapticFeedback.selectionClick();
                _stepCalendar(velocity > 0 ? -1 : 1, daysShowed);
              },
              child: AnimatedSwitcher(
                duration: AppMotion.medium,
                switchInCurve: AppMotion.enter,
                switchOutCurve: AppMotion.exit,
                child: AsyncValueWidget(
                  key: ValueKey(_monthView ? 'month' : 'planner'),
                  value: shiftsAsync,
                  data: (shifts) => _monthView
                      ? FamilyScheduleMonth(
                          key: _monthKey,
                          shifts: shifts,
                          members: members,
                          initialMonth: _monthAnchor,
                          onDayTap: (day) {
                            HapticFeedback.selectionClick();
                            context.push(
                              AppRoutes.daySchedule,
                              extra: {'day': DateTimeUtils.dateOnly(day)},
                            );
                          },
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
                            selection: _selection,
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
                    HapticFeedback.mediumImpact();
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
    HapticFeedback.selectionClick();
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

  void _jumpCalendarTo(DateTime date) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_monthView) {
        _monthKey.currentState?.jumpToDate(date);
      } else {
        _plannerKey.currentState?.jumpToDate(date);
      }
    });
  }
}
