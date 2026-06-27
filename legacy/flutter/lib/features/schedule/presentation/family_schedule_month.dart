import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/presentation/month/schedule_month_grid.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:flutter/material.dart';

/// Month grid with shift chips — thin wrapper around [ScheduleMonthGrid].
class FamilyScheduleMonth extends StatefulWidget {
  const FamilyScheduleMonth({
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
  State<FamilyScheduleMonth> createState() => FamilyScheduleMonthState();
}

class FamilyScheduleMonthState extends State<FamilyScheduleMonth> {
  final _gridKey = GlobalKey<ScheduleMonthGridState>();

  void jumpToDate(DateTime date) {
    _gridKey.currentState?.jumpToMonth(date);
  }

  @override
  Widget build(BuildContext context) {
    return ScheduleMonthGrid(
      key: _gridKey,
      shifts: widget.shifts,
      members: widget.members,
      initialMonth: widget.initialMonth,
      onDayTap: widget.onDayTap,
      onShiftTap: widget.onShiftTap,
      onMonthChange: widget.onMonthChange,
    );
  }
}
