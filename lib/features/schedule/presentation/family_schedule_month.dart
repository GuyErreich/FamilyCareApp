import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/presentation/shift_event_mapper.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

/// Month grid with shift chips, backed by infinite_calendar_view.
class FamilyScheduleMonth extends StatefulWidget {
  const FamilyScheduleMonth({
    required this.shifts,
    required this.members,
    this.initialMonth,
    this.monthKey,
    this.onDayTap,
    this.onShiftTap,
    this.onMonthChange,
    super.key,
  });

  final List<Shift> shifts;
  final List<FamilyMember> members;
  final DateTime? initialMonth;
  final GlobalKey<EventsMonthsState>? monthKey;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<Shift>? onShiftTap;
  final ValueChanged<DateTime>? onMonthChange;

  @override
  State<FamilyScheduleMonth> createState() => _FamilyScheduleMonthState();
}

class _FamilyScheduleMonthState extends State<FamilyScheduleMonth> {
  late final EventsController _controller;

  @override
  void initState() {
    super.initState();
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
    );
    ShiftEventMapper.syncController(controller: _controller, events: events);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final month = widget.initialMonth ?? DateTime.now();

    return EventsMonths(
      key: widget.monthKey,
      controller: _controller,
      initialMonth: DateTime(month.year, month.month),
      onMonthChange: widget.onMonthChange,
      weekParam: const WeekParam(startOfWeekDay: 1, weekHeight: 132),
      daysParam: DaysParam(
        headerHeight: 28,
        eventHeight: 18,
        eventSpacing: 3,
        spaceBetweenHeaderAndEvents: 4,
        dayHeaderBuilder: (day) {
          final isToday = _sameDay(day, DateTime.now());
          return DefaultMonthDayHeader(
            text: '${day.day}',
            isToday: isToday,
            todayBackgroundColor: scheme.primary,
            todayTextColor: scheme.onPrimary,
            textColor: scheme.onSurfaceVariant,
          );
        },
        dayEventBuilder: (event, width, height) {
          final shift = event.data is Shift ? event.data! as Shift : null;
          return DefaultMonthDayEvent(
            event: event,
            fontSize: 10,
            roundBorderRadius: 4,
            onTap: shift == null ? null : () => widget.onShiftTap?.call(shift),
          );
        },
        onDayTapUp: widget.onDayTap,
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
