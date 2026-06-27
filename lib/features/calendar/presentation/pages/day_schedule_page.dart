import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_planner.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_actions.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_slot_confirm_bar.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/presentation/providers/unavailability_providers.dart';
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
    final blocksAsync = ref.watch(dayUnavailabilitiesProvider(day));
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final user = ref.watch(authStateProvider).valueOrNull;
    final canManageOthers = ref.watch(canManageFamilyShiftsProvider);

    return AppScaffold(
      title: DateTimeUtils.formatDate(day),
      showBackButton: true,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
              data: (shifts) => AsyncValueWidget(
                value: blocksAsync,
                data: (blocks) => FamilySchedulePlanner(
                  shifts: shifts,
                  unavailabilities: blocks,
                  members: members,
                  daysShowed: 1,
                  initialDate: day,
                  currentUserId: user?.id,
                  enableSlotSelection: user != null,
                  selection: _selection,
                  onShiftTap: (shift) => context.push('/shifts/${shift.id}'),
                  onUnavailabilityTap: user == null
                      ? null
                      : (block) => showUnavailabilityActions(
                            context,
                            ref,
                            block: block,
                            currentUserId: user.id,
                            canManageOthers: canManageOthers,
                          ),
                  onSlotSelected: user == null
                      ? null
                      : (slot) => setState(() => _selection = slot),
                ),
              ),
            ),
          ),
          if (_selection != null && user != null)
            ScheduleSlotConfirmBar(
              selection: _selection!,
              members: members,
              currentUserId: user.id,
              canManageOthers: canManageOthers,
              onClear: () => setState(() => _selection = null),
              onConfirmShift: (assigneeId) {
                final slot = _selection!;
                setState(() => _selection = null);
                openCreateShiftForSlot(
                  context,
                  selection: slot,
                  userId: assigneeId,
                );
              },
              onConfirmUnavailable: (userId) async {
                final slot = _selection!;
                final familyId = user.familyId;
                if (familyId == null) return;

                final result = await saveUnavailabilityForSlot(
                  ref,
                  selection: slot,
                  userId: userId,
                  familyId: familyId,
                );
                if (!mounted) return;

                setState(() => _selection = null);
                switch (result) {
                  case Success():
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Unavailability saved')),
                    );
                  case Error(:final failure):
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(failure.message)),
                    );
                }
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
