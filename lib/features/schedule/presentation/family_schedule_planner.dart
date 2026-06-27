import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/shift_event_mapper.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

/// Outlook-style day/week planner backed by infinite_calendar_view.
class FamilySchedulePlanner extends StatefulWidget {
  const FamilySchedulePlanner({
    required this.shifts,
    required this.members,
    this.daysShowed = 1,
    this.initialDate,
    this.currentUserId,
    this.enableSlotSelection = true,
    this.plannerKey,
    this.onShiftTap,
    this.onSlotSelected,
    this.onFirstDayChange,
    super.key,
  });

  final List<Shift> shifts;
  final List<FamilyMember> members;
  final int daysShowed;
  final DateTime? initialDate;
  final String? currentUserId;
  final bool enableSlotSelection;
  final GlobalKey<EventsPlannerState>? plannerKey;
  final ValueChanged<Shift>? onShiftTap;
  final ValueChanged<ScheduleSlotSelection?>? onSlotSelected;
  final ValueChanged<DateTime>? onFirstDayChange;

  @override
  State<FamilySchedulePlanner> createState() => _FamilySchedulePlannerState();
}

class _FamilySchedulePlannerState extends State<FamilySchedulePlanner> {
  late final EventsController _controller;

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
    final events = ShiftEventMapper.toEvents(
      shifts: widget.shifts,
      members: widget.members,
      currentUserId: widget.currentUserId,
    );
    ShiftEventMapper.syncController(controller: _controller, events: events);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final heightPerMinute = ScheduleConstants.heightPerMinute;

    return EventsPlanner(
      key: widget.plannerKey,
      controller: _controller,
      daysShowed: widget.daysShowed,
      initialDate: widget.initialDate ?? DateTimeUtils.dateOnly(DateTime.now()),
      heightPerMinute: heightPerMinute,
      daySeparationWidth: ScheduleConstants.daySeparationWidth,
      initialVerticalScrollOffset: ScheduleConstants.initialScrollOffset(),
      minVerticalScrollOffset:
          ScheduleConstants.scrollOffsetForHour(ScheduleConstants.startHour),
      maxVerticalScrollOffset:
          ScheduleConstants.scrollOffsetForHour(ScheduleConstants.endHour),
      onDayChange: widget.onFirstDayChange,
      dayEventsArranger: const SideEventArranger(paddingLeft: 2, paddingRight: 2),
      pinchToZoomParam: PinchToZoomParameters(
        pinchToZoom: true,
        pinchToZoomMinHeightPerMinute: 0.75,
        pinchToZoomMaxHeightPerMinute: 1.8,
      ),
      fullDayParam: const FullDayParam(fullDayEventsBarVisibility: false),
      offTimesParam: OffTimesParam(
        offTimesAllDaysRanges: const [
          OffTimeRange(TimeOfDay(hour: 0, minute: 0), TimeOfDay(hour: 6, minute: 0)),
          OffTimeRange(TimeOfDay(hour: 22, minute: 0), TimeOfDay(hour: 24, minute: 0)),
        ],
        offTimesColor: scheme.surfaceContainerHighest.withValues(alpha: 0.65),
      ),
      daysHeaderParam: DaysHeaderParam(
        daysHeaderHeight: 56,
        daysHeaderColor: scheme.surface,
        dayHeaderBuilder: (day, isToday) => _ScheduleDayHeader(
          day: day,
          isToday: isToday,
        ),
      ),
      timesIndicatorsParam: TimesIndicatorsParam(
        timesIndicatorsWidth: 52,
        timesIndicatorsHorizontalPadding: 6,
        timesIndicatorsCustomPainter: (hpm) => HoursPainter(
          heightPerMinute: hpm,
          showCurrentHour: true,
          hourColor: scheme.onSurfaceVariant.withValues(alpha: 0.45),
          halfHourColor: scheme.outlineVariant.withValues(alpha: 0.35),
          quarterHourColor: scheme.outlineVariant.withValues(alpha: 0.2),
          currentHourIndicatorColor: scheme.primary,
          textPainterBuilder: (time, color) => TextPainter(
            text: TextSpan(
              text: DateTimeUtils.formatTimeOfDay(time),
              style: TextStyle(color: color, fontSize: 11),
            ),
            textDirection: TextDirection.ltr,
            textAlign: TextAlign.right,
          ),
        ),
      ),
      currentHourIndicatorParam: CurrentHourIndicatorParam(
        currentHourIndicatorHourVisibility: true,
        currentHourIndicatorLineVisibility: true,
        currentHourIndicatorColor: scheme.error,
      ),
      dayParam: DayParam(
        todayColor: scheme.primaryContainer.withValues(alpha: 0.12),
        onSlotMinutesRound: ScheduleConstants.snapMinutes,
        dayCustomPainter: (hpm, isToday) => LinesPainter(
          heightPerMinute: hpm,
          isToday: isToday,
          lineColor: scheme.outlineVariant.withValues(alpha: 0.35),
        ),
        dayEventBuilder: (event, height, width, heightPerMinute) {
          final shift = event.data is Shift ? event.data! as Shift : null;
          return DefaultDayEvent(
            height: height,
            width: width,
            title: event.title,
            description: height >= 48 ? event.description : null,
            color: event.color,
            textColor: event.textColor,
            roundBorderRadius: 10,
            titleFontSize: height < 44 ? 11 : 13,
            descriptionFontSize: 10,
            verticalPadding: 6,
            horizontalPadding: 8,
            onTap: shift == null ? null : () => widget.onShiftTap?.call(shift),
          );
        },
        slotSelectionParam: SlotSelectionParam(
          enableTapSlotSelection: widget.enableSlotSelection,
          enableLongPressSlotSelection: widget.enableSlotSelection,
          enableSlotSelectionResize: widget.enableSlotSelection,
          slotSelectionDefaultDurationInMinutes: (_, _) =>
              ScheduleConstants.defaultDurationMinutes,
          onSlotSelectionChange: widget.enableSlotSelection
              ? (slot) => _handleSlotSelection(slot)
              : null,
          slotSelectionContentBuilder: widget.enableSlotSelection
              ? (slot) => _SlotSelectionPreview(slot: slot)
              : null,
        ),
      ),
    );
  }

  void _handleSlotSelection(SlotSelection? slot) {
    if (slot == null) {
      widget.onSlotSelected?.call(null);
      return;
    }

    if (_overlapsExistingShift(slot)) {
      _controller.changeSlotSelection(null);
      widget.onSlotSelected?.call(null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That time is already covered. Pick an open slot.'),
        ),
      );
      return;
    }

    widget.onSlotSelected?.call(ScheduleSlotSelection.fromSlot(slot));
  }

  bool _overlapsExistingShift(SlotSelection slot) {
    final start = slot.startDateTime;
    final end = start.add(Duration(minutes: slot.durationInMinutes));

    for (final shift in widget.shifts) {
      if (shift.status != ShiftStatus.scheduled) continue;
      if (!_sameDay(shift.date, start)) continue;
      if (start.isBefore(shift.endDateTime) &&
          end.isAfter(shift.startDateTime)) {
        return true;
      }
    }
    return false;
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
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
                color: isToday ? scheme.primary : scheme.onSurfaceVariant,
                fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
              ),
        ),
        const SizedBox(height: 4),
        CircleAvatar(
          radius: 15,
          backgroundColor:
              isToday ? scheme.primary : scheme.surfaceContainerHighest,
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
  const _SlotSelectionPreview({required this.slot});

  final SlotSelection slot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final end = slot.startDateTime.add(Duration(minutes: slot.durationInMinutes));

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.primary, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              DateTimeUtils.formatTimeRange(slot.startDateTime, end),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.primary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
