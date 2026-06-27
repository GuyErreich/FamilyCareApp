import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';

/// Resolves slot drag/resize gestures before parent scroll views claim them.
class EagerVerticalDragGestureRecognizer extends VerticalDragGestureRecognizer {
  EagerVerticalDragGestureRecognizer({super.debugOwner});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

/// Pan gesture that wins over planner scroll so the whole slot can be dragged.
class EagerPanGestureRecognizer extends PanGestureRecognizer {
  EagerPanGestureRecognizer({super.debugOwner});

  @override
  void addAllowedPointer(PointerDownEvent event) {
    super.addAllowedPointer(event);
    resolve(GestureDisposition.accepted);
  }
}

/// Scroll helpers used while moving or resizing a slot selection.
abstract final class SlotPlannerScrollHelper {
  static EventsPlannerState? plannerOf(BuildContext context) =>
      context.findAncestorStateOfType<EventsPlannerState>();

  /// Keeps the timeline following the finger when dragging near viewport edges.
  static void autoScroll(EventsPlannerState planner, Offset globalPosition) {
    final renderBox = planner.context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final local = renderBox.globalToLocal(globalPosition);
    final horizontal = planner.mainHorizontalController;
    final vertical = planner.mainVerticalController;

    if (local.dx > planner.width * 0.88) {
      horizontal.jumpTo(
        (horizontal.offset + 24).clamp(0.0, horizontal.position.maxScrollExtent),
      );
    } else if (local.dx < planner.width * 0.12) {
      horizontal.jumpTo(
        (horizontal.offset - 24).clamp(0.0, horizontal.position.maxScrollExtent),
      );
    }

    final minVertical = planner.widget.minVerticalScrollOffset ?? 0.0;
    final maxVertical = planner.widget.maxVerticalScrollOffset ??
        vertical.position.maxScrollExtent;
    final maxOffset = maxVertical.clamp(0.0, vertical.position.maxScrollExtent);

    if (local.dy > planner.height * 0.88) {
      vertical.jumpTo(
        (vertical.offset + 20).clamp(minVertical, maxOffset),
      );
    } else if (local.dy < planner.height * 0.12) {
      vertical.jumpTo(
        (vertical.offset - 20).clamp(minVertical, maxOffset),
      );
    }
  }

  static double scrollAdjustedDy({
    required Offset globalPosition,
    required Offset dragOriginGlobal,
    required double dragOriginScrollY,
    required double currentScrollY,
  }) =>
      (globalPosition.dy - dragOriginGlobal.dy) +
      (currentScrollY - dragOriginScrollY);

  static double scrollAdjustedDx({
    required Offset globalPosition,
    required Offset dragOriginGlobal,
    required double dragOriginScrollX,
    required double currentScrollX,
  }) =>
      (globalPosition.dx - dragOriginGlobal.dx) +
      (currentScrollX - dragOriginScrollX);
}
