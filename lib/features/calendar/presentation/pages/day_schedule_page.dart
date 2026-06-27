import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_planner.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_actions.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_slot_confirm_bar.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/async_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Full-screen day schedule with a proper back affordance.
class DaySchedulePage extends ConsumerStatefulWidget {
  const DaySchedulePage({required this.day, super.key});

  final DateTime day;

  @override
  ConsumerState<DaySchedulePage> createState() => _DaySchedulePageState();
}

class _DaySchedulePageState extends ConsumerState<DaySchedulePage> {
  ScheduleSlotSelection? _selection;

  @override
  Widget build(BuildContext context) {
    final day = DateTimeUtils.dateOnly(widget.day);
    final shiftsAsync = ref.watch(dayShiftsProvider(day));
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final user = ref.watch(authStateProvider).valueOrNull;

    return AppScaffold(
      title: DateTimeUtils.formatDate(day),
      showBackButton: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: shiftsAsync.when(
              data: (shifts) => ScheduleLegend(
                members: members,
                shifts: shifts,
                currentUserId: user?.id,
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
            ),
          ),
          Expanded(
            child: AsyncValueWidget(
              value: shiftsAsync,
              data: (shifts) => FamilySchedulePlanner(
                shifts: shifts,
                members: members,
                daysShowed: 1,
                initialDate: day,
                currentUserId: user?.id,
                enableSlotSelection: user != null,
                onShiftTap: (shift) => context.push('/shifts/${shift.id}'),
                onSlotSelected: user == null
                    ? null
                    : (slot) => setState(() => _selection = slot),
              ),
            ),
          ),
          if (_selection != null && user != null)
            ScheduleSlotConfirmBar(
              selection: _selection!,
              onClear: () => setState(() => _selection = null),
              onConfirm: () {
                final slot = _selection!;
                setState(() => _selection = null);
                openCreateShiftForSlot(
                  context,
                  selection: slot,
                  userId: user.id,
                );
              },
            ),
        ],
      ),
    );
  }
}

final dayShiftsProvider = StreamProvider.family<List<Shift>, DateTime>((ref, day) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  return ref.watch(shiftRepositoryProvider).watchShiftsForDay(
        familyId: user!.familyId!,
        date: day,
      );
});
