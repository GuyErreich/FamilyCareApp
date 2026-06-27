import 'package:family_care_scheduler/features/schedule/presentation/schedule_view_mode.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Active Day / Week / Calendar mode on the Plan tab (session-only).
final planViewModeProvider =
    StateProvider<ScheduleViewMode>((ref) => ScheduleViewMode.calendar);

/// One-shot focus date when opening Plan from Today or elsewhere.
final planJumpDateProvider = StateProvider<DateTime?>((ref) => null);

/// Opens Plan focused on [date] in day timeline mode.
void openPlanForDate(WidgetRef ref, DateTime date) {
  ref.read(planJumpDateProvider.notifier).state = date;
  ref.read(planViewModeProvider.notifier).state = ScheduleViewMode.day;
}
