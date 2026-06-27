import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/schedule/domain/planner_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/planner/schedule_planner_view.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/domain/entities/unavailability.dart';
import 'package:flutter/material.dart';

/// Outlook-style day/week planner.
class FamilySchedulePlanner extends StatelessWidget {
  const FamilySchedulePlanner({
    required this.shifts,
    this.unavailabilities = const [],
    required this.members,
    this.daysShowed = 1,
    this.initialDate,
    this.currentUserId,
    this.enableSlotSelection = true,
    this.selection,
    this.plannerKey,
    this.onShiftTap,
    this.onUnavailabilityTap,
    this.onSlotSelected,
    this.onFirstDayChange,
    super.key,
  });

  final List<Shift> shifts;
  final List<Unavailability> unavailabilities;
  final List<FamilyMember> members;
  final int daysShowed;
  final DateTime? initialDate;
  final String? currentUserId;
  final bool enableSlotSelection;
  final ScheduleSlotSelection? selection;
  final GlobalKey<SchedulePlannerViewState>? plannerKey;
  final ValueChanged<Shift>? onShiftTap;
  final ValueChanged<Unavailability>? onUnavailabilityTap;
  final ValueChanged<ScheduleSlotSelection?>? onSlotSelected;
  final ValueChanged<DateTime>? onFirstDayChange;

  PlannerSlotSelection? _plannerSelection() {
    final active = selection;
    if (active == null) return null;

    final anchor = DateTimeUtils.dateOnly(initialDate ?? DateTime.now());
    final columnIndex =
        DateTimeUtils.dateOnly(active.date).difference(anchor).inDays;

    return PlannerSlotSelection(
      columnIndex: columnIndex.clamp(0, daysShowed - 1),
      initialStartDateTime: active.startDateTime,
      startDateTime: active.startDateTime,
      durationInMinutes: active.durationMinutes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SchedulePlannerView(
      key: plannerKey,
      shifts: shifts,
      unavailabilities: unavailabilities,
      members: members,
      daysShowed: daysShowed,
      initialDate: initialDate,
      currentUserId: currentUserId,
      enableSlotSelection: enableSlotSelection,
      selection: _plannerSelection(),
      onShiftTap: onShiftTap,
      onUnavailabilityTap: onUnavailabilityTap,
      onFirstDayChange: onFirstDayChange,
      onSlotSelected: onSlotSelected,
    );
  }
}
