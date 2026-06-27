import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/core/theme/app_motion.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/domain/entities/app_user.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_month.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_planner.dart';
import 'package:family_care_scheduler/features/schedule/presentation/plan_view_mode_provider.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner/schedule_planner_view.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_actions.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_toolbar.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_member_filter.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_month_year_picker.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_my_upcoming_sheet.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_plan_mode_bar.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_quick_add_sheet.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_slot_actions_sheet.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/presentation/providers/unavailability_providers.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/async_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Plan tab — day/week timelines and month calendar for scheduling.
class CalendarPage extends ConsumerStatefulWidget {
  const CalendarPage({super.key});

  @override
  ConsumerState<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends ConsumerState<CalendarPage> {
  late DateTime _focusedDate;
  ScheduleSlotSelection? _selection;
  final _plannerKey = GlobalKey<SchedulePlannerViewState>();
  final _monthKey = GlobalKey<FamilyScheduleMonthState>();

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTimeUtils.dateOnly(DateTime.now());
  }

  DateTime get _weekStart => DateTimeUtils.startOfWeek(_focusedDate);

  DateTime get _monthAnchor => DateTime(_focusedDate.year, _focusedDate.month);

  DateTime _plannerStartFor(ScheduleViewMode mode) =>
      mode == ScheduleViewMode.week
          ? _weekStart
          : DateTimeUtils.dateOnly(_focusedDate);

  String _toolbarLabelFor(ScheduleViewMode mode) {
    if (mode.isMonthGrid) return DateTimeUtils.formatMonthYear(_monthAnchor);
    final start = _plannerStartFor(mode);
    if (mode == ScheduleViewMode.week) {
      return 'Week of ${DateTimeUtils.formatDate(start)}';
    }
    return DateTimeUtils.formatDate(start);
  }

  void _onModeChanged(ScheduleViewMode mode) {
    ref.read(planViewModeProvider.notifier).state = mode;
    setState(() {
      _selection = null;
      if (mode == ScheduleViewMode.week) {
        _focusedDate = _weekStart;
      }
    });
    final target = mode.isMonthGrid
        ? _monthAnchor
        : _plannerStartFor(mode);
    _jumpCalendarTo(target);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<DateTime?>(planJumpDateProvider, (previous, next) {
      if (next == null) return;
      ref.read(planJumpDateProvider.notifier).state = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _focusedDate = DateTimeUtils.dateOnly(next);
          _selection = null;
        });
        _jumpCalendarTo(next);
      });
    });

    final mode = ref.watch(planViewModeProvider);
    final isMonth = mode.isMonthGrid;
    final plannerDays = mode.plannerDays;
    final plannerStart = _plannerStartFor(mode);
    final shiftsAsync = isMonth
        ? ref.watch(monthShiftsProvider(_monthAnchor))
        : ref.watch(rangeShiftsProvider((plannerStart, plannerDays)));
    final blocksAsync = isMonth
        ? ref.watch(monthUnavailabilitiesProvider(_monthAnchor))
        : ref.watch(rangeUnavailabilitiesProvider((plannerStart, plannerDays)));
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final canManageOthers = ref.watch(canManageFamilyShiftsProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final memberFilter = ref.watch(scheduleMemberFilterProvider);
    final mineOnly = memberFilter == ScheduleMemberFilter.mineOnly;
    final today = DateTimeUtils.dateOnly(DateTime.now());
    final viewingToday =
        !isMonth && DateUtils.isSameDay(_focusedDate, today);

    List<Shift> filterShifts(List<Shift> shifts) =>
        ScheduleMemberFilterUtils.filterShifts(
          shifts: shifts,
          filter: memberFilter,
          currentUserId: user?.id,
        );

    final upcomingShiftsAsync = ref.watch(rangeShiftsProvider((today, 14)));
    final quickAddShiftsAsync = ref.watch(rangeShiftsProvider((today, 30)));

    return AppScaffold(
      title: 'Plan',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SchedulePlanModeBar(
            mode: mode,
            onModeChanged: _onModeChanged,
          ),
          ScheduleCalendarToolbar(
            label: _toolbarLabelFor(mode),
            onPrevious: () => _stepCalendar(-1),
            onNext: () => _stepCalendar(1),
            onToday: _goToToday,
            onLabelTap: _pickMonthYear,
            mineFilterActive: mineOnly,
            onMineFilterTap: user == null
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    ref.read(scheduleMemberFilterProvider.notifier).state =
                        mineOnly
                            ? ScheduleMemberFilter.all
                            : ScheduleMemberFilter.mineOnly;
                  },
            onUpcomingTap: user == null
                ? null
                : () {
                    showScheduleMyUpcomingSheet(
                      context,
                      shifts: upcomingShiftsAsync.valueOrNull ?? [],
                      currentUserId: user.id,
                    );
                  },
            onQuickAddTap: user == null
                ? null
                : () => _openQuickAdd(
                      quickAddShiftsAsync.valueOrNull ??
                          shiftsAsync.valueOrNull ??
                          const [],
                    ),
          ),
          if (viewingToday && mode == ScheduleViewMode.day)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => context.go(AppRoutes.dashboard),
                  icon: const Icon(Icons.today_outlined, size: 18),
                  label: const Text('View in Today'),
                ),
              ),
            ),
          if (!isMonth)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: shiftsAsync.when(
                data: (shifts) => ScheduleLegend(
                  members: members,
                  shifts: filterShifts(shifts),
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
                _stepCalendar(velocity > 0 ? -1 : 1);
              },
              child: AnimatedSwitcher(
                duration: AppMotion.medium,
                switchInCurve: AppMotion.enter,
                switchOutCurve: AppMotion.exit,
                child: AsyncValueWidget(
                  key: ValueKey(isMonth ? 'month' : 'planner-${mode.name}'),
                  value: shiftsAsync,
                  data: (shifts) {
                    final visibleShifts = filterShifts(shifts);
                    return isMonth
                        ? FamilyScheduleMonth(
                            key: _monthKey,
                            shifts: visibleShifts,
                            members: members,
                            initialMonth: _monthAnchor,
                            onDayTap: (day) {
                              HapticFeedback.selectionClick();
                              openPlanForDate(ref, day);
                            },
                            onShiftTap: (shift) =>
                                context.push('/shifts/${shift.id}'),
                          )
                        : AsyncValueWidget(
                            value: blocksAsync,
                            data: (blocks) {
                              final visibleBlocks =
                                  ScheduleMemberFilterUtils.filterUnavailabilities(
                                blocks: blocks,
                                filter: memberFilter,
                                currentUserId: user?.id,
                              );
                              return FamilySchedulePlanner(
                                plannerKey: _plannerKey,
                                shifts: visibleShifts,
                                unavailabilities: visibleBlocks,
                                members: members,
                                daysShowed: plannerDays,
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
                                    : (slot) =>
                                        setState(() => _selection = slot),
                                onSlotConfirmTap: user == null || _selection == null
                                    ? null
                                    : () => _openSlotActions(
                                          user: user,
                                          members: members,
                                          canManageOthers: canManageOthers,
                                          existingShifts: shifts,
                                        ),
                              );
                            },
                          );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openSlotActions({
    required AppUser user,
    required List<FamilyMember> members,
    required bool canManageOthers,
    required List<Shift> existingShifts,
  }) async {
    final selection = _selection;
    if (selection == null) return;

    await showScheduleSlotActionsSheet(
      context,
      selection: selection,
      members: members,
      currentUserId: user.id,
      canManageOthers: canManageOthers,
      existingShifts: existingShifts,
      onConfirmShift: (assigneeId) {
        final slot = selection;
        setState(() => _selection = null);
        openCreateShiftForSlot(
          context,
          selection: slot,
          userId: assigneeId,
        );
      },
      onConfirmUnavailable: (userId) async {
        final slot = selection;
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
    );
  }

  Future<void> _openQuickAdd(List<Shift> existingShifts) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final mode = ref.read(planViewModeProvider);
    final isMonth = mode.isMonthGrid;

    final result = await showScheduleQuickAddSheet(
      context,
      initialDate: isMonth ? _monthAnchor : _focusedDate,
      allowPlaceOnCalendar: !isMonth,
      existingShifts: existingShifts,
    );
    if (result == null || !mounted) return;

    switch (result.action) {
      case ScheduleQuickAddResult.placeOnCalendar:
        setState(() {
          _selection = result.selection;
          _focusedDate = DateTimeUtils.dateOnly(result.selection.date);
        });
        _jumpCalendarTo(result.selection.date);
      case ScheduleQuickAddResult.continueToCreate:
        if (isMonth) {
          openPlanForDate(
            ref,
            DateTimeUtils.dateOnly(result.selection.date),
          );
        }
        openCreateShiftForSlot(
          context,
          selection: result.selection,
          userId: user.id,
        );
    }
  }

  Future<void> _pickMonthYear() async {
    final mode = ref.read(planViewModeProvider);
    final isMonth = mode.isMonthGrid;
    final initial = isMonth ? _monthAnchor : _focusedDate;
    final picked = await showScheduleMonthYearPicker(
      context,
      initial: initial,
    );
    if (picked == null || !mounted) return;

    final monthStart = DateTime(picked.year, picked.month);
    setState(() {
      _focusedDate = isMonth
          ? monthStart
          : mode == ScheduleViewMode.week
              ? DateTimeUtils.startOfWeek(monthStart)
              : monthStart;
      _selection = null;
    });

    _jumpCalendarTo(isMonth ? monthStart : _plannerStartFor(mode));
  }

  void _stepCalendar(int direction) {
    final mode = ref.read(planViewModeProvider);
    final isMonth = mode.isMonthGrid;
    final step = isMonth
        ? 1
        : mode == ScheduleViewMode.week
            ? 7
            : 1;
    final target = isMonth
        ? DateTime(_focusedDate.year, _focusedDate.month + direction)
        : _focusedDate.add(Duration(days: step * direction));

    setState(() {
      _focusedDate = target;
      _selection = null;
    });

    _jumpCalendarTo(isMonth ? _monthAnchor : _plannerStartFor(mode));
  }

  void _goToToday() {
    HapticFeedback.selectionClick();
    final mode = ref.read(planViewModeProvider);
    final isMonth = mode.isMonthGrid;
    final now = DateTime.now();
    setState(() {
      _focusedDate = isMonth
          ? DateTime(now.year, now.month)
          : mode == ScheduleViewMode.week
              ? DateTimeUtils.startOfWeek(now)
              : DateTimeUtils.dateOnly(now);
      _selection = null;
    });

    _jumpCalendarTo(now);
  }

  void _jumpCalendarTo(DateTime date) {
    final isMonth = ref.read(planViewModeProvider).isMonthGrid;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (isMonth) {
        _monthKey.currentState?.jumpToDate(date);
      } else {
        _plannerKey.currentState?.jumpToDate(date);
      }
    });
  }
}
