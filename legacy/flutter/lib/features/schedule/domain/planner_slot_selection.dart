/// Active slot selection on the planner grid (drag / resize).
class PlannerSlotSelection {
  const PlannerSlotSelection({
    required this.columnIndex,
    required this.initialStartDateTime,
    required this.startDateTime,
    required this.durationInMinutes,
  });

  final int columnIndex;
  final DateTime initialStartDateTime;
  final DateTime startDateTime;
  final int durationInMinutes;

  DateTime get endDateTime =>
      startDateTime.add(Duration(minutes: durationInMinutes));

  PlannerSlotSelection copyWith({
    int? columnIndex,
    DateTime? initialStartDateTime,
    DateTime? startDateTime,
    int? durationInMinutes,
  }) {
    return PlannerSlotSelection(
      columnIndex: columnIndex ?? this.columnIndex,
      initialStartDateTime:
          initialStartDateTime ?? this.initialStartDateTime,
      startDateTime: startDateTime ?? this.startDateTime,
      durationInMinutes: durationInMinutes ?? this.durationInMinutes,
    );
  }
}
