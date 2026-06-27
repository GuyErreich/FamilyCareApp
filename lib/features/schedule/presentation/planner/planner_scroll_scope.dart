import 'package:flutter/material.dart';

/// Exposes planner scroll and layout to slot drag helpers.
class PlannerScrollScope extends InheritedWidget {
  const PlannerScrollScope({
    required this.verticalController,
    required this.heightPerMinute,
    required this.dayColumnWidth,
    required this.viewportWidth,
    required this.viewportHeight,
    required super.child,
    super.key,
  });

  final ScrollController verticalController;
  final double heightPerMinute;
  final double dayColumnWidth;
  final double viewportWidth;
  final double viewportHeight;

  static PlannerScrollScope? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PlannerScrollScope>();
  }

  static PlannerScrollScope of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'PlannerScrollScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(PlannerScrollScope oldWidget) {
    return verticalController != oldWidget.verticalController ||
        heightPerMinute != oldWidget.heightPerMinute ||
        dayColumnWidth != oldWidget.dayColumnWidth ||
        viewportWidth != oldWidget.viewportWidth ||
        viewportHeight != oldWidget.viewportHeight;
  }
}
