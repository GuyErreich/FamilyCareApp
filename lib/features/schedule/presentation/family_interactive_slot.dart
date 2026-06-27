import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/schedule/domain/slot_overlap_resolver.dart';
import 'package:family_care_scheduler/features/schedule/presentation/slot_move_session.dart';
import 'package:family_care_scheduler/features/schedule/presentation/slot_planner_scroll_helper.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

typedef SlotChangedCallback = void Function(
  SlotSelection? slot, {
  required bool isDragging,
  required bool hasConflict,
});

/// Draggable, resizable slot selection without the library's tap-to-dismiss behavior.
class FamilyInteractiveSlot extends StatefulWidget {
  const FamilyInteractiveSlot({
    required this.slot,
    required this.dayWidth,
    required this.heightPerMinute,
    required this.shifts,
    required this.onChanged,
    this.onConflictChanged,
    required this.content,
    super.key,
  });

  final SlotSelection slot;
  final double dayWidth;
  final double heightPerMinute;
  final List<Shift> shifts;
  final SlotChangedCallback onChanged;
  final ValueChanged<bool>? onConflictChanged;
  final Widget Function(SlotSelection slot, {required bool hasConflict}) content;

  @override
  State<FamilyInteractiveSlot> createState() => _FamilyInteractiveSlotState();
}

class _FamilyInteractiveSlotState extends State<FamilyInteractiveSlot> {
  EventsPlannerState? _planner;
  Offset? _dragOriginGlobal;
  double _dragOriginScrollY = 0;

  DateTime? _topResizeStart;
  DateTime? _topResizeEnd;
  int? _bottomResizeDuration;

  int? _pendingPointer;
  var _hasConflict = false;

  static const double _minHandleHeight = 8;
  static const double _maxHandleHeight = 12;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = _hasConflict ? scheme.error : scheme.primary;
    final fillColor = _hasConflict
        ? scheme.error.withValues(alpha: 0.2)
        : scheme.primary.withValues(alpha: 0.16);

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        final useColumnLayout = totalHeight >= 48;
        final handleHeight = useColumnLayout
            ? (totalHeight * 0.12).clamp(_minHandleHeight, _maxHandleHeight)
            : (totalHeight * 0.2).clamp(4.0, 8.0);

        final decoration = BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 2),
        );

        final content = Listener(
          onPointerDown: (event) => _pendingPointer = event.pointer,
          child: RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: {
              EagerPanGestureRecognizer: _moveGesture(),
            },
            child: widget.content(
              widget.slot,
              hasConflict: _hasConflict,
            ),
          ),
        );

        if (useColumnLayout) {
          return DecoratedBox(
            decoration: decoration,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: handleHeight,
                    child: _ResizeHandle(
                      color: borderColor,
                      onVerticalDrag: _topHandleGesture(),
                    ),
                  ),
                  Expanded(child: content),
                  SizedBox(
                    height: handleHeight,
                    child: _ResizeHandle(
                      color: borderColor,
                      onVerticalDrag: _bottomHandleGesture(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return DecoratedBox(
          decoration: decoration,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: handleHeight),
                    child: content,
                  ),
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: handleHeight,
                  child: _ResizeHandle(
                    color: borderColor,
                    onVerticalDrag: _topHandleGesture(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: handleHeight,
                  child: _ResizeHandle(
                    color: borderColor,
                    onVerticalDrag: _bottomHandleGesture(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  GestureRecognizerFactoryWithHandlers<PanGestureRecognizer> _moveGesture() {
    return GestureRecognizerFactoryWithHandlers<EagerPanGestureRecognizer>(
      EagerPanGestureRecognizer.new,
      (instance) {
        instance.onStart = (details) => _beginMove(details.globalPosition);
        instance.onUpdate = (details) {
          SlotMoveSession.moveIfActive(details.globalPosition);
        };
        instance.onEnd = (details) {
          SlotMoveSession.finish(details.globalPosition);
        };
        instance.onCancel = () => SlotMoveSession.end();
      },
    );
  }

  void _beginMove(Offset globalPosition) {
    final pointer = _pendingPointer;
    if (pointer == null || SlotMoveSession.isActive) return;

    final planner = SlotPlannerScrollHelper.plannerOf(context);
    if (planner == null) return;

    SlotMoveSession.start(
      pointer: pointer,
      drag: SlotDragContext(
        planner: planner,
        dragStartAnchor: widget.slot.startDateTime,
        initialGlobal: globalPosition,
        initialScrollY: planner.mainVerticalController.offset,
        initialScrollX: planner.mainHorizontalController.offset,
        dayWidth: widget.dayWidth,
        heightPerMinute: widget.heightPerMinute,
        durationMinutes: widget.slot.durationInMinutes,
        columnIndex: widget.slot.columnIndex,
        initialStartDateTime: widget.slot.initialStartDateTime,
        shifts: widget.shifts,
        onChanged: widget.onChanged,
        onConflictChanged: (hasConflict) {
          widget.onConflictChanged?.call(hasConflict);
          if (mounted && hasConflict != _hasConflict) {
            setState(() => _hasConflict = hasConflict);
          }
        },
      ),
    );
    SlotMoveSession.moveIfActive(globalPosition);
  }

  GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>
      _topHandleGesture() {
    return GestureRecognizerFactoryWithHandlers<
        EagerVerticalDragGestureRecognizer>(
      EagerVerticalDragGestureRecognizer.new,
      (instance) {
        instance.onStart = (details) {
          _planner = SlotPlannerScrollHelper.plannerOf(context);
          _topResizeStart = widget.slot.startDateTime;
          _topResizeEnd = widget.slot.startDateTime
              .add(Duration(minutes: widget.slot.durationInMinutes));
          _dragOriginGlobal = details.globalPosition;
          _dragOriginScrollY = _planner?.mainVerticalController.offset ?? 0;
        };
        instance.onUpdate = (details) {
          final planner = _planner;
          final resizeStart = _topResizeStart;
          final resizeEnd = _topResizeEnd;
          final origin = _dragOriginGlobal;
          if (planner == null ||
              resizeStart == null ||
              resizeEnd == null ||
              origin == null) {
            return;
          }

          SlotPlannerScrollHelper.autoScroll(planner, details.globalPosition);

          final dy = SlotPlannerScrollHelper.scrollAdjustedDy(
            globalPosition: details.globalPosition,
            dragOriginGlobal: origin,
            dragOriginScrollY: _dragOriginScrollY,
            currentScrollY: planner.mainVerticalController.offset,
          );

          const snap = ScheduleConstants.snapMinutes;
          final minutesDelta =
              snap * ((dy / widget.heightPerMinute) / snap).round();
          if (minutesDelta == 0) return;

          final rawStart = ScheduleConstants.snapToGrid(
            resizeStart.add(Duration(minutes: minutesDelta)),
          );
          final newDuration = resizeEnd.difference(rawStart).inMinutes;
          if (newDuration < snap) return;

          final placement = SlotOverlapResolver.resolveFree(
            proposedStart: rawStart,
            durationMinutes: newDuration,
            shifts: widget.shifts,
          );

          _emitSlot(
            start: placement.start,
            duration: placement.durationMinutes,
            isDragging: true,
            hasConflict: placement.hasConflict,
          );
        };
        instance.onEnd = (_) {
          final placement = SlotOverlapResolver.resolve(
            proposedStart: widget.slot.startDateTime,
            durationMinutes: widget.slot.durationInMinutes,
            shifts: widget.shifts,
          );
          _emitSlot(
            start: placement.start,
            duration: placement.durationMinutes,
            isDragging: false,
            hasConflict: placement.hasConflict,
          );
          _clearResizeTop();
        };
      },
    );
  }

  GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>
      _bottomHandleGesture() {
    return GestureRecognizerFactoryWithHandlers<
        EagerVerticalDragGestureRecognizer>(
      EagerVerticalDragGestureRecognizer.new,
      (instance) {
        instance.onStart = (details) {
          _planner = SlotPlannerScrollHelper.plannerOf(context);
          _bottomResizeDuration = widget.slot.durationInMinutes;
          _dragOriginGlobal = details.globalPosition;
          _dragOriginScrollY = _planner?.mainVerticalController.offset ?? 0;
        };
        instance.onUpdate = (details) {
          final planner = _planner;
          final originDuration = _bottomResizeDuration;
          final origin = _dragOriginGlobal;
          if (planner == null || originDuration == null || origin == null) {
            return;
          }

          SlotPlannerScrollHelper.autoScroll(planner, details.globalPosition);

          final dy = SlotPlannerScrollHelper.scrollAdjustedDy(
            globalPosition: details.globalPosition,
            dragOriginGlobal: origin,
            dragOriginScrollY: _dragOriginScrollY,
            currentScrollY: planner.mainVerticalController.offset,
          );

          const snap = ScheduleConstants.snapMinutes;
          final minutesDelta =
              snap * ((dy / widget.heightPerMinute) / snap).round();
          if (minutesDelta == 0) return;

          final startMinutes = widget.slot.startDateTime.hour * 60 +
              widget.slot.startDateTime.minute;
          final maxDuration = ScheduleConstants.minutesPerDay - startMinutes;
          final snappedDuration = (ScheduleConstants.snapMinutes *
                  ((originDuration + minutesDelta) / ScheduleConstants.snapMinutes)
                      .round())
              .clamp(snap, maxDuration);
          if (snappedDuration == widget.slot.durationInMinutes) return;

          final placement = SlotOverlapResolver.resolveDurationFree(
            start: widget.slot.startDateTime,
            proposedDurationMinutes: snappedDuration,
            shifts: widget.shifts,
          );

          _emitSlot(
            start: placement.start,
            duration: placement.durationMinutes,
            isDragging: true,
            hasConflict: placement.hasConflict,
          );
        };
        instance.onEnd = (_) {
          final placement = SlotOverlapResolver.resolveDuration(
            start: widget.slot.startDateTime,
            proposedDurationMinutes: widget.slot.durationInMinutes,
            shifts: widget.shifts,
          );
          _emitSlot(
            start: placement.start,
            duration: placement.durationMinutes,
            isDragging: false,
            hasConflict: placement.hasConflict,
          );
          _clearResizeBottom();
        };
      },
    );
  }

  void _emitSlot({
    required DateTime start,
    required int duration,
    required bool isDragging,
    required bool hasConflict,
  }) {
    if (mounted && hasConflict != _hasConflict) {
      setState(() => _hasConflict = hasConflict);
    }

    widget.onChanged(
      SlotSelection(
        widget.slot.columnIndex,
        widget.slot.initialStartDateTime,
        start,
        duration,
      ),
      isDragging: isDragging,
      hasConflict: hasConflict,
    );
  }

  void _clearResizeTop() {
    _topResizeStart = null;
    _topResizeEnd = null;
    _dragOriginGlobal = null;
    _planner = null;
    if (mounted) {
      setState(() => _hasConflict = false);
    }
  }

  void _clearResizeBottom() {
    _bottomResizeDuration = null;
    _dragOriginGlobal = null;
    _planner = null;
    if (mounted) {
      setState(() => _hasConflict = false);
    }
  }
}

class _ResizeHandle extends StatelessWidget {
  const _ResizeHandle({
    required this.color,
    required this.onVerticalDrag,
  });

  final Color color;
  final GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>
      onVerticalDrag;

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        EagerVerticalDragGestureRecognizer: onVerticalDrag,
      },
      child: Center(
        child: Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
