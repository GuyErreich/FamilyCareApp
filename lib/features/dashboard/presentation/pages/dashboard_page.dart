import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/dashboard/domain/usecases/get_today_schedule_use_case.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
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

final todayShiftsProvider = StreamProvider<List<Shift>>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user?.familyId == null) return const Stream.empty();
  return ref.watch(shiftRepositoryProvider).watchShiftsForDay(
        familyId: user!.familyId!,
        date: DateTime.now(),
      );
});

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  ScheduleSlotSelection? _selection;

  @override
  Widget build(BuildContext context) {
    final shiftsAsync = ref.watch(todayShiftsProvider);
    final membersAsync = ref.watch(familyMembersProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final today = DateTimeUtils.dateOnly(DateTime.now());

    return AppScaffold(
      title: 'Schedule',
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateTimeUtils.formatDate(today),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap an open slot to assign yourself',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueWidget(
              value: shiftsAsync,
              data: (shifts) {
                final schedule = const GetTodayScheduleUseCase().call(shifts);
                final members = membersAsync.valueOrNull ?? [];

                return Column(
                  children: [
                    if (schedule.hasMissingCoverage)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: ListTile(
                            leading: const Icon(Icons.warning_amber),
                            title: const Text('Gaps in today\'s coverage'),
                            subtitle: const Text(
                              'Choose an open time on the schedule below.',
                            ),
                            trailing: user == null
                                ? null
                                : TextButton(
                                    onPressed: () => _clearAndCreate(
                                      context,
                                      user.id,
                                      today,
                                    ),
                                    child: const Text('Take now'),
                                  ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: ScheduleLegend(
                        members: members,
                        shifts: shifts,
                        currentUserId: user?.id,
                      ),
                    ),
                    Expanded(
                      child: FamilySchedulePlanner(
                        shifts: shifts,
                        members: members,
                        daysShowed: 1,
                        initialDate: today,
                        currentUserId: user?.id,
                        enableSlotSelection: user != null,
                        onShiftTap: (shift) =>
                            context.push('/shifts/${shift.id}'),
                        onSlotSelected: user == null
                            ? null
                            : (slot) => setState(() => _selection = slot),
                      ),
                    ),
                  ],
                );
              },
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

  void _clearAndCreate(BuildContext context, String userId, DateTime today) {
    final now = DateTime.now();
    openCreateShiftForSlot(
      context,
      selection: ScheduleSlotSelection(
        date: today,
        start: TimeOfDay(hour: now.hour, minute: now.minute),
        durationMinutes: ScheduleConstants.defaultDurationMinutes,
      ),
      userId: userId,
    );
  }
}
