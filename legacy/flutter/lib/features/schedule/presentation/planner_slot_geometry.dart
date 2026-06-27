import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';

/// Shared 15-minute slot layout for planner grid and time gutter.
abstract final class PlannerSlotGeometry {
  static int get slotCount =>
      ScheduleConstants.minutesPerDay ~/ ScheduleConstants.snapMinutes;

  static double slotHeight(double heightPerMinute) =>
      heightPerMinute * ScheduleConstants.snapMinutes;

  static double yForSlot(int slotIndex, double heightPerMinute) =>
      slotIndex * slotHeight(heightPerMinute);

  static double yForMinutes(int totalMinutes, double heightPerMinute) =>
      totalMinutes * heightPerMinute;
}
