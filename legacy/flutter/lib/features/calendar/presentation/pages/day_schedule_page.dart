import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/domain/entities/app_user.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_slot_selection.dart';
import 'package:family_care_scheduler/features/schedule/presentation/family_schedule_planner.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_actions.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_member_filter.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_quick_add_sheet.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_slot_actions_sheet.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/features/unavailability/presentation/providers/unavailability_providers.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/async_value_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Full-screen shifts view for one day (opened from Overview).
class ShiftsViewPage extends ConsumerStatefulWidget {
  const ShiftsViewPage({required this.day, super.key});

  final DateTime day;

  @override
  ConsumerState<ShiftsViewPage> createState() => _ShiftsViewPageState();
}

class _ShiftsViewPageState extends ConsumerState<ShiftsViewPage> {
  ScheduleSlotSelection? _selection;

  Future<void> _openQuickAdd(List<Shift> existingShifts) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final result = await showScheduleQuickAddSheet(
      context,
      initialDate: widget.day,
      allowPlaceOnCalendar: true,
      existingShifts: existingShifts,
    );
    if (result == null || !mounted) return;

    switch (result.action) {
      case ScheduleQuickAddResult.placeOnCalendar:
        setState(() => _selection = result.selection);
      case ScheduleQuickAddResult.continueToCreate:
        openCreateShiftForSlot(
          context,
          selection: result.selection,
          userId: user.id,
        );
    }
  }

  Future<void> _openSlotActions({
    required AppUser user,
    required List<FamilyMember> members,
    required bool canManageOthers,
    required List<Shift> existingShifts,
  }) async {
    final selection = _selection;
    if (selection == null) return;

    await showScheduleSlotActionsSheet(
      context,
      selection: selection,
      members: members,
      currentUserId: user.id,
      canManageOthers: canManageOthers,
      existingShifts: existingShifts,
      onConfirmShift: (assigneeId) {
        final slot = selection;
        setState(() => _selection = null);
        openCreateShiftForSlot(
          context,
          selection: slot,
          userId: assigneeId,
        );
      },
      onConfirmUnavailable: (userId) async {
        final slot = selection;
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final day = DateTimeUtils.dateOnly(widget.day);
    final shiftsAsync = ref.watch(dayShiftsProvider(day));
    final blocksAsync = ref.watch(dayUnavailabilitiesProvider(day));
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final user = ref.watch(authStateProvider).valueOrNull;
    final canManageOthers = ref.watch(canManageFamilyShiftsProvider);
    final memberFilter = ref.watch(scheduleMemberFilterProvider);

    List<Shift> filterShifts(List<Shift> shifts) =>
        ScheduleMemberFilterUtils.filterShifts(
          shifts: shifts,
          filter: memberFilter,
          currentUserId: user?.id,
        );

    final shiftsForAdd = shiftsAsync.valueOrNull;

    return AppScaffold(
      title: 'Shifts',
      showBackButton: true,
      floatingActionButton: user == null || shiftsForAdd == null
          ? null
          : FloatingActionButton(
              onPressed: () => _openQuickAdd(shiftsForAdd),
              tooltip: 'Add shift',
              child: const Icon(Icons.add),
            ),
      actions: user == null || shiftsForAdd == null
          ? null
          : [
              IconButton(
                onPressed: () => _openQuickAdd(shiftsForAdd),
                icon: const Icon(Icons.add),
                tooltip: 'Add shift',
              ),
            ],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                DateTimeUtils.formatDate(day),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: shiftsAsync.when(
              data: (shifts) => ScheduleLegend(
                members: members,
                shifts: filterShifts(shifts),
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
                data: (blocks) {
                  final visibleShifts = filterShifts(shifts);
                  final visibleBlocks =
                      ScheduleMemberFilterUtils.filterUnavailabilities(
                    blocks: blocks,
                    filter: memberFilter,
                    currentUserId: user?.id,
                  );

                  return FamilySchedulePlanner(
                    shifts: visibleShifts,
                    unavailabilities: visibleBlocks,
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
                    onSlotConfirmTap: user == null || _selection == null
                        ? null
                        : () => _openSlotActions(
                              user: user,
                              members: members,
                              canManageOthers: canManageOthers,
                              existingShifts: shifts,
                            ),
                  );
                },
              ),
            ),
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
