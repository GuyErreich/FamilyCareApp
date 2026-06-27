import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/planner_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_timeline_item.dart';
import 'package:family_care_scheduler/features/schedule/domain/slot_overlap_resolver.dart';
import 'package:family_care_scheduler/features/schedule/domain/timeline_layout_engine.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner/planner_day_column.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner/planner_day_header_row.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner/planner_scroll_scope.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner_slot_painters.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_style.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_timeline_mapper.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter/material.dart';

/// First-party day/week planner timeline.
class SchedulePlannerView extends StatefulWidget {
  const SchedulePlannerView({
    required this.shifts,
    required this.unavailabilities,
    required this.members,
    required this.daysShowed,
    this.initialDate,
    this.currentUserId,
    this.enableSlotSelection = true,
    this.selection,
    this.onShiftTap,
    this.onUnavailabilityTap,
    this.onSlotSelected,
    this.onSlotConfirmTap,
    this.onFirstDayChange,
    super.key,
  });

  final List<Shift> shifts;
  final List<Unavailability> unavailabilities;
  final List<FamilyMember> members;
  final int daysShowed;
  final DateTime? initialDate;
  final String? currentUserId;
  final bool enableSlotSelection;
  final PlannerSlotSelection? selection;
  final ValueChanged<Shift>? onShiftTap;
  final ValueChanged<Unavailability>? onUnavailabilityTap;
  final ValueChanged<ScheduleSlotSelection?>? onSlotSelected;
  final VoidCallback? onSlotConfirmTap;
  final ValueChanged<DateTime>? onFirstDayChange;

  @override
  State<SchedulePlannerView> createState() => SchedulePlannerViewState();
}

class SchedulePlannerViewState extends State<SchedulePlannerView> {
  static const _timeGutterWidth = 56.0;

  late final ScrollController _verticalController;
  late DateTime _firstDay;
  var _viewportWidth = 0.0;
  var _viewportHeight = 0.0;

  @override
  void initState() {
    super.initState();
    _firstDay = DateTimeUtils.dateOnly(
      widget.initialDate ?? DateTime.now(),
    );
    _verticalController = ScrollController(
      initialScrollOffset: ScheduleConstants.initialScrollOffset(),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onFirstDayChange?.call(_firstDay);
    });
  }

  @override
  void didUpdateWidget(covariant SchedulePlannerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialDate;
    if (next != null) {
      final day = DateTimeUtils.dateOnly(next);
      if (day != _firstDay) {
        setState(() => _firstDay = day);
        widget.onFirstDayChange?.call(_firstDay);
      }
    }
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

  void jumpToDate(DateTime date) {
    final day = DateTimeUtils.dateOnly(date);
    setState(() => _firstDay = day);
    widget.onFirstDayChange?.call(_firstDay);
    if (DateUtils.isSameDay(day, DateTime.now())) {
      scrollToMinutes(
        DateTime.now().hour * 60 + DateTime.now().minute - 45,
      );
    }
  }

  void scrollToMinutes(int minutes) {
    if (!_verticalController.hasClients) return;
    final offset = ScheduleConstants.scrollOffsetForMinutes(
      minutes.clamp(0, ScheduleConstants.minutesPerDay - 1),
    );
    _verticalController.jumpTo(
      offset.clamp(0.0, _verticalController.position.maxScrollExtent),
    );
  }

  List<DateTime> get _days => [
        for (var i = 0; i < widget.daysShowed; i++)
          _firstDay.add(Duration(days: i)),
      ];

  double get _timelineHeight =>
      ScheduleConstants.scrollOffsetForMinutes(ScheduleConstants.minutesPerDay);

  double get _heightPerMinute => ScheduleConstants.heightPerMinute;

  List<ScheduleTimelineItem> get _allItems =>
      ScheduleTimelineMapper.toItems(
        shifts: widget.shifts,
        unavailabilities: widget.unavailabilities,
        members: widget.members,
        currentUserId: widget.currentUserId,
      );

  void _handleSlotTap(DateTime day, int columnIndex, Offset localPosition) {
    if (!widget.enableSlotSelection) return;

    final rawMinutes = (localPosition.dy / _heightPerMinute).round();
    const snap = ScheduleConstants.snapMinutes;
    final snappedMinutes = (rawMinutes / snap).round() * snap;
    final clampedMinutes = snappedMinutes.clamp(
      0,
      ScheduleConstants.minutesPerDay - ScheduleConstants.defaultDurationMinutes,
    );
    final start = ScheduleConstants.snapToGrid(
      day.add(Duration(minutes: clampedMinutes)),
    );

    if (SlotOverlapResolver.overlapsShift(
      start: start,
      durationMinutes: ScheduleConstants.defaultDurationMinutes,
      shifts: widget.shifts,
    )) {
      widget.onSlotSelected?.call(null);
      return;
    }

    final slot = PlannerSlotSelection(
      columnIndex: columnIndex,
      initialStartDateTime: start,
      startDateTime: start,
      durationInMinutes: ScheduleConstants.defaultDurationMinutes,
    );
    widget.onSlotSelected?.call(ScheduleSlotSelection.fromPlannerSlot(slot));
  }

  void _handleSlotChanged(
    PlannerSlotSelection? slot, {
    required bool isDragging,
    required bool hasConflict,
  }) {
    if (slot == null) {
      widget.onSlotSelected?.call(null);
      return;
    }

    if (!isDragging &&
        SlotOverlapResolver.overlapsShift(
          start: slot.startDateTime,
          durationMinutes: slot.durationInMinutes,
          shifts: widget.shifts,
        )) {
      widget.onSlotSelected?.call(null);
      return;
    }

    if (hasConflict && !isDragging) {
      widget.onSlotSelected?.call(null);
      return;
    }

    widget.onSlotSelected?.call(ScheduleSlotSelection.fromPlannerSlot(slot));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dayColumnWidth = _viewportWidth > 0
        ? (_viewportWidth - _timeGutterWidth) / widget.daysShowed
        : 0.0;

    return DecoratedBox(
      decoration: ScheduleCalendarStyle.calendarFrame(scheme),
      child: Column(
        children: [
          PlannerDayHeaderRow(
            days: _days,
            timeGutterWidth: _timeGutterWidth,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                _viewportWidth = constraints.maxWidth;
                _viewportHeight = constraints.maxHeight;

                return PlannerScrollScope(
                  verticalController: _verticalController,
                  heightPerMinute: _heightPerMinute,
                  dayColumnWidth: dayColumnWidth,
                  viewportWidth: _viewportWidth,
                  viewportHeight: _viewportHeight,
                  child: SingleChildScrollView(
                      controller: _verticalController,
                      child: SizedBox(
                        height: _timelineHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: _timeGutterWidth,
                              height: _timelineHeight,
                              child: CustomPaint(
                                painter: PlannerTimeGutterPainter(
                                  scheme: scheme,
                                  heightPerMinute: _heightPerMinute,
                                ),
                              ),
                            ),
                            for (var i = 0; i < _days.length; i++)
                              Expanded(
                                child: PlannerDayColumn(
                                  day: _days[i],
                                  isToday: DateUtils.isSameDay(
                                    _days[i],
                                    DateTime.now(),
                                  ),
                                  timelineHeight: _timelineHeight,
                                  heightPerMinute: _heightPerMinute,
                                  placedItems: TimelineLayoutEngine.layout(
                                    ScheduleTimelineMapper.itemsForDay(
                                      items: _allItems,
                                      day: _days[i],
                                    ),
                                  ),
                                  shifts: widget.shifts,
                                  columnIndex: i,
                                  selection: widget.selection,
                                  enableSlotSelection:
                                      widget.enableSlotSelection,
                                  onShiftTap: widget.onShiftTap,
                                  onUnavailabilityTap:
                                      widget.onUnavailabilityTap,
                                  onSlotTap: (day, position) =>
                                      _handleSlotTap(day, i, position),
                                  onSlotChanged: _handleSlotChanged,
                                  onSlotConfirmTap: widget.onSlotConfirmTap,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
