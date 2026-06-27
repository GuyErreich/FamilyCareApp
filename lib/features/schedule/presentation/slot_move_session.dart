import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/schedule/domain/slot_overlap_resolver.dart';
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

/// Drag state that outlives [FamilyInteractiveSlot] rebuilds across days.
final class SlotDragContext {
  SlotDragContext({
    required this.planner,
    required this.dragStartAnchor,
    required this.initialGlobal,
    required this.initialScrollY,
    required this.initialScrollX,
    required this.dayWidth,
    required this.heightPerMinute,
    required this.durationMinutes,
    required this.columnIndex,
    required this.initialStartDateTime,
    required this.shifts,
    required this.onChanged,
    required this.onConflictChanged,
  });

  final EventsPlannerState planner;
  final DateTime dragStartAnchor;
  final Offset initialGlobal;
  final double initialScrollY;
  final double initialScrollX;
  final double dayWidth;
  final double heightPerMinute;
  final int durationMinutes;
  final int columnIndex;
  final DateTime initialStartDateTime;
  final List<Shift> shifts;
  final SlotChangedCallback onChanged;
  final ValueChanged<bool> onConflictChanged;

  void move(Offset globalPosition, {required bool isDragging}) {
    SlotPlannerScrollHelper.autoScroll(planner, globalPosition);

    final scrollY = planner.mainVerticalController.offset;
    final scrollX = planner.mainHorizontalController.offset;

    final dy = (globalPosition.dy - initialGlobal.dy) + (scrollY - initialScrollY);
    final dx = (globalPosition.dx - initialGlobal.dx) + (scrollX - initialScrollX);

    const snap = ScheduleConstants.snapMinutes;
    final minutesDelta = snap * (dy / heightPerMinute / snap).round();
    final daysDelta = (dx / dayWidth).round();
    final rawStart = ScheduleConstants.snapToGrid(
      dragStartAnchor.add(
        Duration(days: daysDelta, minutes: minutesDelta),
      ),
    );

    final placement = isDragging
        ? SlotOverlapResolver.resolveFree(
            proposedStart: rawStart,
            durationMinutes: durationMinutes,
            shifts: shifts,
          )
        : SlotOverlapResolver.resolve(
            proposedStart: rawStart,
            durationMinutes: durationMinutes,
            shifts: shifts,
          );

    onConflictChanged(placement.hasConflict);
    onChanged(
      SlotSelection(
        columnIndex,
        initialStartDateTime,
        placement.start,
        placement.durationMinutes,
      ),
      isDragging: isDragging,
      hasConflict: placement.hasConflict,
    );
  }
}

/// Keeps slot move gestures alive across planner rebuilds via [PointerRouter].
abstract final class SlotMoveSession {
  static int? _activePointer;
  static SlotDragContext? _context;
  static void Function(PointerEvent)? _route;

  static bool get isActive => _context != null;

  static void start({
    required int pointer,
    required SlotDragContext drag,
  }) {
    end();
    _activePointer = pointer;
    _context = drag;
    _route = _handlePointerEvent;
    GestureBinding.instance.pointerRouter.addRoute(pointer, _route!);
  }

  static void moveIfActive(Offset globalPosition) {
    if (!isActive) return;
    _context!.move(globalPosition, isDragging: true);
  }

  static void finish(Offset globalPosition) {
    if (!isActive) return;
    _context!.move(globalPosition, isDragging: false);
    end();
  }

  static void _handlePointerEvent(PointerEvent event) {
    if (event.pointer != _activePointer) return;

    switch (event) {
      case PointerMoveEvent():
        _context?.move(event.position, isDragging: true);
      case PointerUpEvent():
        _context?.move(event.position, isDragging: false);
        end();
      case PointerCancelEvent():
        end();
      default:
        break;
    }
  }

  static void end() {
    if (_activePointer != null && _route != null) {
      GestureBinding.instance.pointerRouter.removeRoute(
        _activePointer!,
        _route!,
      );
    }
    _route = null;
    _activePointer = null;
    _context = null;
  }
}
