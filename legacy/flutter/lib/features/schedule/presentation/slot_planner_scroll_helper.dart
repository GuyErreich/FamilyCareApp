import 'package:family_care_scheduler/features/schedule/presentation/planner/planner_scroll_scope.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

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
  static PlannerScrollScope? scopeOf(BuildContext context) {
    return PlannerScrollScope.maybeOf(context);
  }

  /// Keeps the timeline following the finger when dragging near viewport edges.
  static void autoScroll(
    BuildContext context,
    PlannerScrollScope scope,
    Offset globalPosition,
  ) {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final local = renderBox.globalToLocal(globalPosition);
    final vertical = scope.verticalController;

    final maxOffset = vertical.position.maxScrollExtent;

    if (local.dy > scope.viewportHeight * 0.88) {
      vertical.jumpTo(
        (vertical.offset + 20).clamp(0.0, maxOffset),
      );
    } else if (local.dy < scope.viewportHeight * 0.12) {
      vertical.jumpTo(
        (vertical.offset - 20).clamp(0.0, maxOffset),
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
}
