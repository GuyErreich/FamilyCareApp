import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/domain/slot_overlap_resolver.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner_slot_painters.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_interactive_slot.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_style.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_event_mapper.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

/// Outlook-style day/week planner backed by infinite_calendar_view.
class FamilySchedulePlanner extends StatefulWidget {
  const FamilySchedulePlanner({
    required this.shifts,
    this.unavailabilities = const [],
    required this.members,
    this.daysShowed = 1,
    this.initialDate,
    this.currentUserId,
    this.enableSlotSelection = true,
    this.plannerKey,
    this.onShiftTap,
    this.onUnavailabilityTap,
    this.onSlotSelected,
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
  final GlobalKey<EventsPlannerState>? plannerKey;
  final ValueChanged<Shift>? onShiftTap;
  final ValueChanged<Unavailability>? onUnavailabilityTap;
  final ValueChanged<ScheduleSlotSelection?>? onSlotSelected;
  final ValueChanged<DateTime>? onFirstDayChange;

  @override
  State<FamilySchedulePlanner> createState() => _FamilySchedulePlannerState();
}

class _FamilySchedulePlannerState extends State<FamilySchedulePlanner> {
  late final EventsController _controller;
  var _slotDragConflict = false;

  @override
  void initState() {
    super.initState();
    _controller = EventsController();
    _syncEvents();
  }

  @override
  void didUpdateWidget(covariant FamilySchedulePlanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shifts != widget.shifts ||
        oldWidget.unavailabilities != widget.unavailabilities ||
        oldWidget.members != widget.members ||
        oldWidget.currentUserId != widget.currentUserId) {
      _syncEvents();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _syncEvents() {
    final events = ScheduleEventMapper.toEvents(
      shifts: widget.shifts,
      unavailabilities: widget.unavailabilities,
      members: widget.members,
      currentUserId: widget.currentUserId,
    );
    ScheduleEventMapper.syncController(controller: _controller, events: events);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final heightPerMinute = ScheduleConstants.heightPerMinute;

    return DecoratedBox(
      decoration: ScheduleCalendarStyle.calendarFrame(scheme),
      child: EventsPlanner(
          key: widget.plannerKey,
          controller: _controller,
          daysShowed: widget.daysShowed,
          initialDate:
              widget.initialDate ?? DateTimeUtils.dateOnly(DateTime.now()),
          heightPerMinute: heightPerMinute,
          daySeparationWidth: ScheduleConstants.daySeparationWidth,
          initialVerticalScrollOffset: ScheduleConstants.initialScrollOffset(),
          maxVerticalScrollOffset: ScheduleConstants.scrollOffsetForMinutes(
            ScheduleConstants.minutesPerDay,
          ),
          onDayChange: widget.onFirstDayChange,
          automaticAdjustHorizontalScrollToDay: false,
          dayEventsArranger:
              const SideEventArranger(paddingLeft: 3, paddingRight: 3),
          pinchToZoomParam: PinchToZoomParameters(
            pinchToZoom: true,
            pinchToZoomMinHeightPerMinute: 0.75,
            pinchToZoomMaxHeightPerMinute: 1.8,
          ),
          fullDayParam: const FullDayParam(fullDayEventsBarVisibility: false),
          offTimesParam: OffTimesParam(
            offTimesAllDaysRanges: const [
              OffTimeRange(
                TimeOfDay(hour: 0, minute: 0),
                TimeOfDay(hour: 24, minute: 0),
              ),
            ],
            offTimesAllDaysPainter:
                (column, day, isToday, heightPerMinute, ranges, color) {
              return PlannerDaySlotBackgroundPainter(
                scheme: scheme,
                day: day,
                isToday: isToday,
                heightPerMinute: heightPerMinute,
              );
            },
          ),
          daysHeaderParam: DaysHeaderParam(
            daysHeaderHeight: 58,
            daysHeaderColor: scheme.surfaceContainerLow,
            dayHeaderBuilder: (day, isToday) => ColoredBox(
              color: ScheduleCalendarStyle.plannerDayHeaderColor(
                scheme,
                isToday: isToday,
              ),
              child: _ScheduleDayHeader(
                day: day,
                isToday: isToday,
              ),
            ),
          ),
          timesIndicatorsParam: TimesIndicatorsParam(
            timesIndicatorsWidth: 56,
            timesIndicatorsHorizontalPadding: 8,
            timesIndicatorsCustomPainter: (hpm) => PlannerTimeGutterPainter(
              scheme: scheme,
              heightPerMinute: hpm,
            ),
          ),
          currentHourIndicatorParam: CurrentHourIndicatorParam(
            currentHourIndicatorHourVisibility: true,
            currentHourIndicatorLineVisibility: true,
            currentHourIndicatorColor: scheme.error,
          ),
          dayParam: DayParam(
            dayTopPadding: 0,
            dayBottomPadding: 0,
            onSlotMinutesRound: ScheduleConstants.snapMinutes,
            dayCustomPainter: (hpm, isToday) =>
                ScheduleCalendarStyle.plannerGridPainter(
              heightPerMinute: hpm,
              scheme: scheme,
            ),
            dayEventBuilder: (event, height, width, heightPerMinute) {
              final shift = event.data is Shift ? event.data! as Shift : null;
              final block = event.data is Unavailability
                  ? event.data! as Unavailability
                  : null;
              return DefaultDayEvent(
                height: height,
                width: width,
                title: event.title,
                description: height >= 48 ? event.description : null,
                color: event.color,
                textColor: event.textColor,
                roundBorderRadius: 12,
                titleFontSize: height < 44 ? 11 : 13,
                descriptionFontSize: 10,
                verticalPadding: 6,
                horizontalPadding: 8,
                onTap: shift != null
                    ? () => widget.onShiftTap?.call(shift)
                    : block != null
                        ? () => widget.onUnavailabilityTap?.call(block)
                        : null,
              );
            },
            slotSelectionParam: SlotSelectionParam(
              enableTapSlotSelection: widget.enableSlotSelection,
              enableLongPressSlotSelection: widget.enableSlotSelection,
              enableSlotSelectionResize: widget.enableSlotSelection,
              canDragSlotSelectionAfterShow: true,
              clearWhenBackgroundTap: true,
              slotSelectionDefaultDurationInMinutes: (_, _) =>
                  ScheduleConstants.defaultDurationMinutes,
              onSlotSelectionChange: widget.enableSlotSelection
                  ? (slot) => _handleSlotSelection(slot)
                  : null,
              slotSelectionBuilder: widget.enableSlotSelection
                  ? (slot, dayWidth, dayParam, columnsParam, heightPerMinute,
                      onChanged) {
                      return FamilyInteractiveSlot(
                        slot: slot,
                        dayWidth: dayWidth,
                        heightPerMinute: heightPerMinute,
                        shifts: widget.shifts,
                        onConflictChanged: (hasConflict) {
                          if (_slotDragConflict != hasConflict) {
                            setState(() => _slotDragConflict = hasConflict);
                          }
                        },
                        onChanged: (updated,
                            {required isDragging, required hasConflict}) {
                          if (!isDragging && _slotDragConflict) {
                            setState(() => _slotDragConflict = false);
                          }
                          onChanged(updated);
                          _handleSlotSelection(
                            updated,
                            isDragging: isDragging,
                            hasConflict: hasConflict,
                          );
                        },
                        content: (activeSlot, {required bool hasConflict}) =>
                            _SlotSelectionPreview(
                          slot: activeSlot,
                          hasConflict: hasConflict || _slotDragConflict,
                        ),
                      );
                    }
                  : null,
            ),
          ),
        ),
    );
  }

  void _handleSlotSelection(
    SlotSelection? slot, {
    bool isDragging = false,
    bool hasConflict = false,
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

    widget.onSlotSelected?.call(ScheduleSlotSelection.fromSlot(slot));
  }
}

class _ScheduleDayHeader extends StatelessWidget {
  const _ScheduleDayHeader({
    required this.day,
    required this.isToday,
  });

  final DateTime day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          labels[day.weekday - 1],
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isToday
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.75),
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: 16,
          backgroundColor: isToday
              ? scheme.primary
              : scheme.surfaceContainerHigh,
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isToday ? scheme.onPrimary : scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _SlotSelectionPreview extends StatelessWidget {
  const _SlotSelectionPreview({
    required this.slot,
    this.hasConflict = false,
  });

  final SlotSelection slot;
  final bool hasConflict;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final end = slot.startDateTime.add(Duration(minutes: slot.durationInMinutes));
    final timeLabel = DateTimeUtils.formatTimeRange(slot.startDateTime, end);

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final showDetail = height >= 36;
        final showTimeOnly = height >= 12;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: showDetail
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasConflict ? 'Time taken' : 'You',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: hasConflict ? scheme.error : scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      timeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: hasConflict ? scheme.error : scheme.primary,
                          ),
                    ),
                  ],
                )
              : showTimeOnly
                  ? Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        timeLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: hasConflict ? scheme.error : scheme.primary,
                              fontSize: 9,
                            ),
                      ),
                    )
                  : const SizedBox.shrink(),
        );
      },
    );
  }
}
