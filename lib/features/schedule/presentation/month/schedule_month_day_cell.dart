import 'package:family_care_scheduler/features/schedule/presentation/month/schedule_month_event_chip.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_style.dart';
import 'package:family_care_scheduler/features/schedule/presentation/month/month_shift_chip_data.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/material.dart';

/// Single day cell in the month grid.
class ScheduleMonthDayCell extends StatelessWidget {
  const ScheduleMonthDayCell({
    required this.day,
    required this.isToday,
    required this.isOutsideMonth,
    required this.chips,
    required this.maxEvents,
    required this.eventHeight,
    required this.eventSpacing,
    this.onDayTap,
    this.onShiftTap,
    this.onMoreTap,
    super.key,
  });

  final DateTime day;
  final bool isToday;
  final bool isOutsideMonth;
  final List<MonthShiftChipData> chips;
  final int maxEvents;
  final double eventHeight;
  final double eventSpacing;
  final ValueChanged<DateTime>? onDayTap;
  final ValueChanged<Shift>? onShiftTap;
  final ValueChanged<DateTime>? onMoreTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visibleCount = maxEvents > 0 ? maxEvents.clamp(0, chips.length) : 0;
    final hiddenCount = chips.length - visibleCount;
    final showMore = hiddenCount > 0 && maxEvents > 0;
    final eventSlots = showMore ? maxEvents : visibleCount;
    final todayDecoration = ScheduleCalendarStyle.monthDayCellDecoration(
      scheme,
      isToday: isToday,
      isOutsideMonth: isOutsideMonth,
    );

    return GestureDetector(
      onTap: () => onDayTap?.call(day),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 2, 2, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.center,
              child: Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: todayDecoration,
                child: Text(
                  '${day.day}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isToday
                            ? scheme.onPrimaryContainer
                            : ScheduleCalendarStyle.monthDayNumberColor(
                                scheme,
                                isToday: false,
                              ).withValues(
                                alpha: isOutsideMonth ? 0.4 : 1,
                              ),
                      ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            Expanded(
              child: Column(
                children: [
                  for (var i = 0; i < eventSlots; i++)
                    if (showMore && i == eventSlots - 1)
                      Padding(
                        padding: EdgeInsets.only(bottom: eventSpacing),
                        child: SizedBox(
                          height: eventHeight,
                          child: Material(
                            color: scheme.surfaceContainerHigh
                                .withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              onTap: () => onMoreTap?.call(day),
                              borderRadius: BorderRadius.circular(10),
                              child: Center(
                                child: Text(
                                  '+$hiddenCount more',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                        color: scheme.primary,
                                        fontSize: 10,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else if (i < chips.length)
                      Padding(
                        padding: EdgeInsets.only(bottom: eventSpacing),
                        child: SizedBox(
                          height: eventHeight,
                          child: ScheduleMonthEventChip(
                            label: chips[i].title,
                            color: chips[i].color,
                            onTap: onShiftTap == null
                                ? null
                                : () => onShiftTap!(chips[i].shift),
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
