import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/presentation/month/month_shift_chip_data.dart';
import 'package:family_care_scheduler/features/schedule/presentation/month/schedule_month_day_cell.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_style.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_timeline_mapper.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift_status.dart';
import 'package:flutter/material.dart';

class ScheduleMonthGrid extends StatefulWidget {
  const ScheduleMonthGrid({
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
  State<ScheduleMonthGrid> createState() => ScheduleMonthGridState();
}

class ScheduleMonthGridState extends State<ScheduleMonthGrid> {
  static const _weekCount = 6;
  static const _daysPerWeek = 7;

  late DateTime _displayMonth;

  @override
  void initState() {
    super.initState();
    final month = widget.initialMonth ?? DateTime.now();
    _displayMonth = DateTime(month.year, month.month);
  }

  @override
  void didUpdateWidget(covariant ScheduleMonthGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    final month = widget.initialMonth;
    if (month != null) {
      final next = DateTime(month.year, month.month);
      if (next.year != _displayMonth.year || next.month != _displayMonth.month) {
        setState(() => _displayMonth = next);
        widget.onMonthChange?.call(next);
      }
    }
  }

  void jumpToMonth(DateTime date) {
    if (!mounted) return;
    final next = DateTime(date.year, date.month);
    setState(() => _displayMonth = next);
    widget.onMonthChange?.call(next);
  }

  DateTime get _gridStart {
    final monthStart = DateTime(_displayMonth.year, _displayMonth.month);
    return DateTimeUtils.startOfWeek(monthStart);
  }

  List<DateTime> get _gridDays => [
        for (var i = 0; i < _weekCount * _daysPerWeek; i++)
          _gridStart.add(Duration(days: i)),
      ];

  List<MonthShiftChipData> _chipsForDay(DateTime day) {
    final dayOnly = DateTimeUtils.dateOnly(day);
    return widget.shifts
        .where((s) => s.status == ShiftStatus.scheduled)
        .where((s) => DateTimeUtils.dateOnly(s.date) == dayOnly)
        .map((shift) {
          final items = ScheduleTimelineMapper.toItems(
            shifts: [shift],
            unavailabilities: const [],
            members: widget.members,
          );
          final item = items.first;
          return MonthShiftChipData(
            shift: shift,
            title: item.title,
            color: item.color,
          );
        })
        .toList()
      ..sort((a, b) => a.shift.startDateTime.compareTo(b.shift.startDateTime));
  }

  int _maxEventsPerDay(double rowHeight, MonthGridMetrics metrics) {
    final available = rowHeight -
        metrics.headerHeight -
        metrics.spaceBetweenHeaderAndEvents -
        8;
    return ((available + metrics.eventSpacing) /
            (metrics.eventHeight + metrics.eventSpacing))
        .floor()
        .clamp(0, 99);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final metrics = ScheduleCalendarStyle.monthGridMetrics(scheme);

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLowest,
            border: Border.all(
              color: scheme.outlineVariant.withValues(alpha: 0.35),
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
        children: [
          SizedBox(
            height: metrics.headerHeight + 6,
            child: Row(
              children: [
                for (var i = 0; i < metrics.weekdayLabels.length; i++)
                  Expanded(
                    child: Center(
                      child: Text(
                        metrics.weekdayLabels[i],
                        style: metrics.headerStyle.copyWith(
                          color: metrics.headerDayTextColor(i),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final rowHeight = constraints.maxHeight / _weekCount;
                final maxEvents = _maxEventsPerDay(rowHeight, metrics);
                final daySpacing = metrics.daySpacing;

                return Column(
                  children: [
                    for (var week = 0; week < _weekCount; week++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: week < 5 ? 2 : 0),
                          child: Row(
                            children: [
                              for (var dayIndex = 0;
                                  dayIndex < _daysPerWeek;
                                  dayIndex++)
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: daySpacing / 2,
                                    ),
                                    child: Builder(
                                      builder: (context) {
                                        final day = _gridDays[
                                            week * _daysPerWeek + dayIndex];
                                        final isToday = DateUtils.isSameDay(
                                          day,
                                          DateTime.now(),
                                        );
                                        final isOutsideMonth =
                                            day.month != _displayMonth.month;
                                        final chips = _chipsForDay(day);

                                        return ScheduleMonthDayCell(
                                          day: day,
                                          isToday: isToday,
                                          isOutsideMonth: isOutsideMonth,
                                          chips: chips,
                                          maxEvents: maxEvents,
                                          eventHeight: metrics.eventHeight,
                                          eventSpacing: metrics.eventSpacing,
                                          onDayTap: (d) =>
                                              widget.onDayTap?.call(d),
                                          onShiftTap: (s) =>
                                              widget.onShiftTap?.call(s),
                                          onMoreTap: (d) =>
                                              widget.onDayTap?.call(d),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }
}
