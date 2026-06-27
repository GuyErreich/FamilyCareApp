import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/schedule/domain/planner_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_timeline_item.dart';
import 'package:family_care_scheduler/features/schedule/domain/timeline_layout_engine.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_interactive_slot.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner/planner_event_tile.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner_slot_painters.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_calendar_style.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter/material.dart';

/// One day column in the planner timeline.
class PlannerDayColumn extends StatelessWidget {
  const PlannerDayColumn({
    required this.day,
    required this.isToday,
    required this.timelineHeight,
    required this.heightPerMinute,
    required this.placedItems,
    required this.shifts,
    required this.columnIndex,
    required this.selection,
    required this.enableSlotSelection,
    required this.onShiftTap,
    required this.onUnavailabilityTap,
    required this.onSlotTap,
    required this.onSlotChanged,
    this.onSlotConflictChanged,
    this.onSlotConfirmTap,
    super.key,
  });

  final DateTime day;
  final bool isToday;
  final double timelineHeight;
  final double heightPerMinute;
  final List<PlacedTimelineItem> placedItems;
  final List<Shift> shifts;
  final int columnIndex;
  final PlannerSlotSelection? selection;
  final bool enableSlotSelection;
  final ValueChanged<Shift>? onShiftTap;
  final ValueChanged<Unavailability>? onUnavailabilityTap;
  final void Function(DateTime day, Offset localPosition) onSlotTap;
  final SlotChangedCallback onSlotChanged;
  final ValueChanged<bool>? onSlotConflictChanged;
  final VoidCallback? onSlotConfirmTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final showNowLine = isToday && DateUtils.isSameDay(day, now);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GestureDetector(
          onTapDown: enableSlotSelection
              ? (details) => onSlotTap(day, details.localPosition)
              : null,
          onLongPressStart: enableSlotSelection
              ? (details) => onSlotTap(day, details.localPosition)
              : null,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(width, timelineHeight),
                painter: PlannerDaySlotBackgroundPainter(
                  scheme: scheme,
                  day: day,
                  isToday: isToday,
                  heightPerMinute: heightPerMinute,
                ),
              ),
              CustomPaint(
                size: Size(width, timelineHeight),
                painter: ScheduleCalendarStyle.plannerGridPainter(
                  heightPerMinute: heightPerMinute,
                  scheme: scheme,
                ),
              ),
              for (final placed in placedItems)
                Positioned(
                  left: 3 + (placed.columnIndex * (width - 6) / placed.columnCount),
                  top: placed.topMinutes * heightPerMinute,
                  width: (width - 6) / placed.columnCount - 2,
                  height: placed.heightMinutes * heightPerMinute,
                  child: _eventTile(placed),
                ),
              if (showNowLine)
                Positioned(
                  left: 0,
                  right: 0,
                  top: _nowLineY(now) - 1,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: scheme.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: scheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              if (selection != null && selection!.columnIndex == columnIndex)
                Positioned(
                  left: 3,
                  top: _selectionTop(selection!),
                  width: width - 6,
                  height: selection!.durationInMinutes * heightPerMinute,
                  child: FamilyInteractiveSlot(
                    slot: selection!,
                    dayWidth: width,
                    heightPerMinute: heightPerMinute,
                    shifts: shifts,
                    onChanged: onSlotChanged,
                    onConflictChanged: onSlotConflictChanged,
                    onConfirmTap: onSlotConfirmTap,
                    content: (slot, {required bool hasConflict}) =>
                        _SlotSelectionPreview(
                      slot: slot,
                      hasConflict: hasConflict,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  double _nowLineY(DateTime now) {
    final minutes = now.hour * 60 + now.minute + now.second / 60;
    return minutes * heightPerMinute;
  }

  double _selectionTop(PlannerSlotSelection slot) {
    final minutes = slot.startDateTime.hour * 60 + slot.startDateTime.minute;
    return minutes * heightPerMinute;
  }

  Widget _eventTile(PlacedTimelineItem placed) {
    final item = placed.item;
    return PlannerEventTile(
      title: item.title,
      description: item.description,
      color: item.color,
      textColor: item.textColor,
      height: placed.heightMinutes * heightPerMinute,
      isUnavailability: item is UnavailabilityTimelineItem,
      onTap: switch (item) {
        ShiftTimelineItem(:final shift) => onShiftTap == null
            ? null
            : () => onShiftTap!(shift),
        UnavailabilityTimelineItem(:final block) => onUnavailabilityTap == null
            ? null
            : () => onUnavailabilityTap!(block),
      },
    );
  }
}

class _SlotSelectionPreview extends StatelessWidget {
  const _SlotSelectionPreview({
    required this.slot,
    this.hasConflict = false,
  });

  final PlannerSlotSelection slot;
  final bool hasConflict;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final end = slot.endDateTime;
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
