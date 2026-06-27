import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_style.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:infinite_calendar_view/src/utils/default_text.dart';
import 'package:infinite_calendar_view/src/utils/event_helper.dart';

/// Month week row with alternating day-cell backgrounds.
class ScheduleMonthWeek extends StatefulWidget {
  const ScheduleMonthWeek({
    required this.controller,
    required this.textDirection,
    required this.weekParam,
    required this.weekHeight,
    required this.daysParam,
    required this.startOfWeek,
    required this.maxEventsShowed,
    super.key,
  });

  final EventsController controller;
  final TextDirection textDirection;
  final DateTime startOfWeek;
  final WeekParam weekParam;
  final double weekHeight;
  final DaysParam daysParam;
  final int maxEventsShowed;

  @override
  State<ScheduleMonthWeek> createState() => _ScheduleMonthWeekState();
}

class _ScheduleMonthWeekState extends State<ScheduleMonthWeek> {
  late VoidCallback eventListener;
  List<List<Event>?> weekEvents = [];
  List<List<Event?>> weekShowedEvents = [];

  @override
  void initState() {
    super.initState();
    updateEvents();
    eventListener = () => updateEvents();
    widget.controller.addListener(eventListener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(eventListener);
    super.dispose();
  }

  void updateEvents() {
    if (!mounted) return;

    final weekEvents = getWeekEvents();
    final weekShowedEvents =
        getShowedWeekEvents(weekEvents, widget.maxEventsShowed);
    if (!listEquals(weekShowedEvents, this.weekShowedEvents)) {
      setState(() {
        this.weekEvents = weekEvents;
        this.weekShowedEvents = weekShowedEvents;
      });
    }
  }

  List<List<Event>?> getWeekEvents() {
    final eventsList = <List<Event>?>[];
    for (var day = 0; day < 7; day++) {
      eventsList.add(widget.controller.getSortedFilteredDayEvents(
        widget.startOfWeek.addCalendarDays(day),
      ));
    }
    return eventsList;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final daySpacing = widget.weekParam.daySpacing;

    return Container(
      decoration: widget.weekParam.weekDecoration ??
          WeekParam.defaultWeekDecoration(context),
      child: SizedBox(
        height: widget.weekHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final dayWidth = width / 7;

            return DragTarget(
              onAcceptWithDetails: (details) {
                final onDragEnd = details.data as void Function(DateTime);
                final renderBox = context.findRenderObject()! as RenderBox;
                final relativeOffset = renderBox.globalToLocal(
                  Offset(details.offset.dx + dayWidth / 2, details.offset.dy),
                );
                onDragEnd(getPositionDay(relativeOffset, dayWidth));
              },
              builder: (context, candidateData, rejectedData) {
                return GestureDetector(
                  onTapDown: (details) => widget.daysParam.onDayTapDown
                      ?.call(getPositionDay(details.localPosition, dayWidth)),
                  onTapUp: (details) => widget.daysParam.onDayTapUp
                      ?.call(getPositionDay(details.localPosition, dayWidth)),
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Row(
                          textDirection: widget.textDirection,
                          children: [
                            for (var dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++)
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: daySpacing / 2,
                                  ),
                                  child: Builder(
                                    builder: (context) {
                                      final day = widget.startOfWeek
                                          .addCalendarDays(dayOfWeek);
                                      final isToday =
                                          DateUtils.isSameDay(day, DateTime.now());
                                      return DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: ScheduleCalendarStyle
                                              .monthDayCellColor(
                                            scheme,
                                            isToday: isToday,
                                            isOutsideMonth: false,
                                          ),
                                          border: ScheduleCalendarStyle
                                              .monthDayCellBorder(
                                            scheme,
                                            isToday: isToday,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          SizedBox(
                            height: widget.daysParam.headerHeight,
                            child: Row(
                              textDirection: widget.textDirection,
                              children: [
                                for (var dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++)
                                  Expanded(child: getHeaderWidget(dayOfWeek)),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: widget.weekHeight -
                                widget.daysParam.headerHeight,
                            child: Stack(
                              children: [
                                for (var dayOfWeek = 0; dayOfWeek < 7; dayOfWeek++)
                                  for (var eventIndex = 0;
                                      eventIndex <
                                          weekShowedEvents[dayOfWeek].length;
                                      eventIndex++)
                                    if (eventIndex < widget.maxEventsShowed)
                                      ...getEventOrMoreEventsWidget(
                                        dayOfWeek,
                                        eventIndex,
                                        dayWidth,
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  DateTime getPositionDay(Offset localPosition, double dayWidth) {
    final position = (localPosition.dx / dayWidth).toInt();
    final dayOfWeek = widget.textDirection == TextDirection.ltr
        ? position
        : 6 - position;
    return widget.startOfWeek.addCalendarDays(dayOfWeek);
  }

  Widget getHeaderWidget(int dayOfWeek) {
    final day = widget.startOfWeek.addCalendarDays(dayOfWeek);
    final isStartOfMonth = day.day == 1;
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: widget.daysParam.headerHeight,
      child: widget.daysParam.dayHeaderBuilder?.call(day) ??
          DefaultMonthDayHeader(
            text: widget.daysParam.dayHeaderTextBuilder?.call(day) ??
                (isStartOfMonth
                    ? '${defaultMonthAbrText[day.month - 1]} 1'
                    : day.day.toString()),
            isToday: DateUtils.isSameDay(day, DateTime.now()),
            textColor: isStartOfMonth
                ? colorScheme.onSurface
                : colorScheme.outline,
          ),
    );
  }

  List<Widget> getEventOrMoreEventsWidget(
    int dayOfWeek,
    int eventIndex,
    double dayWidth,
  ) {
    final daySpacing = widget.weekParam.daySpacing;
    final eventSpacing = widget.daysParam.eventSpacing;
    final eventHeight = widget.daysParam.eventHeight;
    final horizontalPosition = dayOfWeek * dayWidth + (daySpacing / 2);
    final eventsLength = weekEvents[dayOfWeek]?.length ?? 0;
    final day = widget.startOfWeek.addCalendarDays(dayOfWeek);

    final isLastSlot = eventIndex == widget.maxEventsShowed - 1;
    final notShowedEventsCount = (eventsLength - widget.maxEventsShowed) + 1;
    if (isLastSlot && notShowedEventsCount > 1) {
      return [
        Positioned(
          left: widget.textDirection == TextDirection.ltr
              ? horizontalPosition
              : null,
          right: widget.textDirection == TextDirection.rtl
              ? horizontalPosition
              : null,
          top: (widget.maxEventsShowed - 1) * (eventHeight + eventSpacing),
          width: dayWidth - daySpacing,
          height: eventHeight,
          child: widget.daysParam.dayMoreEventsBuilder
                  ?.call(notShowedEventsCount, day) ??
              DefaultNotShowedMonthEventsWidget(
                context: context,
                eventHeight: eventHeight,
                text: '$notShowedEventsCount others',
              ),
        ),
      ];
    }

    final event = weekShowedEvents[dayOfWeek][eventIndex];
    final isMultiDayOtherDay = (event?.daysIndex ?? 0) > 0 && dayOfWeek > 0;
    if (event != null && !isMultiDayOtherDay) {
      var duration = 1;
      while (true) {
        final nextDayOfWeek = dayOfWeek + duration;
        if (nextDayOfWeek >= 7) break;

        final nextEvent =
            weekShowedEvents.getOrNull(nextDayOfWeek)?.getOrNull(eventIndex);
        if (nextEvent?.uniqueId != event.uniqueId) break;

        final isLastVisibleLane = eventIndex == widget.maxEventsShowed - 1;
        if (isLastVisibleLane) {
          final nextDayRawCount = weekEvents[nextDayOfWeek]?.length ?? 0;
          final nextDayShowsMore =
              (nextDayRawCount - widget.maxEventsShowed) + 1 > 1;
          if (nextDayShowsMore) break;
        }

        duration++;
      }
      final eventWidth = (dayWidth * duration) - daySpacing;
      final top = weekShowedEvents[dayOfWeek].indexOf(event) *
          (eventHeight + eventSpacing);
      return [
        Positioned(
          left: widget.textDirection == TextDirection.ltr
              ? horizontalPosition
              : null,
          right: widget.textDirection == TextDirection.rtl
              ? horizontalPosition
              : null,
          top: top,
          width: eventWidth,
          height: eventHeight,
          child: widget.daysParam.dayEventBuilder?.call(
                event,
                eventWidth,
                eventHeight,
              ) ??
              DefaultMonthDayEvent(event: event),
        ),
      ];
    }

    return [];
  }
}
