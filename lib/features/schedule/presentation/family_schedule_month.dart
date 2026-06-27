import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_style.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_month_week.dart';
import 'package:family_care_scheduler/features/schedule/presentation/shift_event_mapper.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

/// Month grid with shift chips and alternating day-cell backgrounds.
class FamilyScheduleMonth extends StatefulWidget {
  const FamilyScheduleMonth({
    required this.shifts,
    required this.members,
    this.initialMonth,
    this.onDayTap,
    this.onShiftTap,
    this.onMonthChange,
    super.key,
  });

  final List<Shift> shifts;
  final List<FamilyMember> members;
  final DateTime? initialMonth;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<Shift>? onShiftTap;
  final ValueChanged<DateTime>? onMonthChange;

  @override
  State<FamilyScheduleMonth> createState() => FamilyScheduleMonthState();
}

class FamilyScheduleMonthState extends State<FamilyScheduleMonth> {
  late final EventsController _controller;
  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final month = widget.initialMonth ?? DateTime.now();
    _displayMonth = DateTime(month.year, month.month);
    _controller = EventsController();
    _syncEvents();
  }

  @override
  void didUpdateWidget(covariant FamilyScheduleMonth oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shifts != widget.shifts ||
        oldWidget.members != widget.members) {
      _syncEvents();
    }
    final month = widget.initialMonth;
    if (month != null) {
      final next = DateTime(month.year, month.month);
      if (next.year != _displayMonth.year || next.month != _displayMonth.month) {
        setState(() => _displayMonth = next);
        widget.onMonthChange?.call(next);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void jumpToDate(DateTime date) {
    if (!mounted) return;
    final next = DateTime(date.year, date.month);
    setState(() => _displayMonth = next);
    widget.onMonthChange?.call(next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.notifyListeners();
    });
  }

  void _syncEvents() {
    final events = ShiftEventMapper.toEvents(
      shifts: widget.shifts,
      members: widget.members,
    );
    ShiftEventMapper.syncController(controller: _controller, events: events);
  }

  int _maxEventsShowed(WeekParam weekParam, DaysParam daysParam) {
    final dayHeight = weekParam.weekHeight;
    final headerHeight = daysParam.headerHeight;
    final eventHeight = daysParam.eventHeight;
    final space = daysParam.eventSpacing;
    final beforeEventSpacing = daysParam.spaceBetweenHeaderAndEvents;
    return ((dayHeight - headerHeight - beforeEventSpacing + space) /
            (eventHeight + space))
        .toInt();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final weekParam = ScheduleCalendarStyle.monthWeekParam(scheme);
    final daysParam = DaysParam(
      headerHeight: 28,
      eventHeight: 18,
      eventSpacing: 3,
      spaceBetweenHeaderAndEvents: 4,
      dayHeaderBuilder: (day) {
        final isToday = _sameDay(day, DateTime.now());
        return DefaultMonthDayHeader(
          text: '${day.day}',
          isToday: isToday,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          todayBackgroundColor: scheme.primary,
          todayTextColor: scheme.onPrimary,
          textColor: ScheduleCalendarStyle.monthDayNumberColor(
            scheme,
            isToday: isToday,
          ),
        );
      },
      dayEventBuilder: (event, width, height) {
        final shift = event.data is Shift ? event.data! as Shift : null;
        return DefaultMonthDayEvent(
          event: event,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          roundBorderRadius: 8,
          onTap: shift == null ? null : () => widget.onShiftTap?.call(shift),
        );
      },
      onDayTapUp: widget.onDayTap,
    );
    final maxEventsShowed = _maxEventsShowed(weekParam, daysParam);
    final startOfWeeks = <DateTime>[];
    var startOfWeek = _displayMonth.startOfWeek(weekParam.startOfWeekDay);
    while (startOfWeek.addCalendarDays(6).month == _displayMonth.month) {
      startOfWeeks.add(startOfWeek);
      startOfWeek = startOfWeek.addCalendarDays(7);
    }

    return DecoratedBox(
      decoration: ScheduleCalendarStyle.calendarFrame(scheme),
      child: Column(
        children: [
          MonthHeader(
            textDirection: Directionality.of(context),
            weekParam: weekParam,
          ),
          Expanded(
            child: Column(
              children: [
                for (final weekStart in startOfWeeks)
                  ScheduleMonthWeek(
                    controller: _controller,
                    textDirection: Directionality.of(context),
                    weekParam: weekParam,
                    weekHeight: weekParam.weekHeight,
                    daysParam: daysParam,
                    startOfWeek: weekStart,
                    maxEventsShowed: maxEventsShowed,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
