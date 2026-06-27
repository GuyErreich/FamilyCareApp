import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/dashboard/domain/usecases/get_today_schedule_use_case.dart';
import 'package:family_care_scheduler/features/family/domain/entities/family_member.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/shifts/domain/entities/shift.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:family_care_scheduler/shared/widgets/async_value_widget.dart';
import 'package:family_care_scheduler/shared/widgets/member_avatar.dart';
import 'package:family_care_scheduler/shared/widgets/primary_button.dart';
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

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(todayShiftsProvider);
    final membersAsync = ref.watch(familyMembersProvider);
    final user = ref.watch(authStateProvider).valueOrNull;

    return AppScaffold(
      title: 'Today',
      floatingActionButton: user == null
          ? null
          : FloatingActionButton.extended(
              onPressed: () => context.push(
                AppRoutes.createShift,
                extra: {
                  'date': DateTime.now(),
                  'userId': user.id,
                },
              ),
              icon: const Icon(Icons.add),
              label: const Text('Take Shift'),
            ),
      body: AsyncValueWidget(
        value: shiftsAsync,
        data: (shifts) {
          final schedule = const GetTodayScheduleUseCase().call(shifts);
          final members = membersAsync.valueOrNull ?? [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (schedule.hasMissingCoverage)
                Card(
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: const ListTile(
                    leading: Icon(Icons.warning_amber),
                    title: Text('No companion scheduled today'),
                    subtitle: Text('Tap Take Shift to cover today.'),
                  ),
                ),
              const SizedBox(height: 8),
              Text('Current companion', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (schedule.current != null)
                _ShiftCard(shift: schedule.current!, members: members)
              else
                const Card(
                  child: ListTile(
                    title: Text('No one is on shift right now'),
                  ),
                ),
              const SizedBox(height: 24),
              Text('Upcoming', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (schedule.upcoming.isEmpty)
                const Card(
                  child: ListTile(title: Text('No more shifts today')),
                )
              else
                ...schedule.upcoming.map(
                  (shift) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: _ShiftCard(shift: shift, members: members),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ShiftCard extends StatelessWidget {
  const _ShiftCard({required this.shift, required this.members});

  final Shift shift;
  final List<FamilyMember> members;

  @override
  Widget build(BuildContext context) {
    final member = members.cast<FamilyMember?>().firstWhere(
          (m) => m?.userId == shift.assignedUserId,
          orElse: () => members.cast<FamilyMember?>().firstWhere(
                (m) => m?.id == shift.assignedUserId,
                orElse: () => null,
              ),
        );

    return Card(
      child: ListTile(
        leading: member != null ? MemberAvatar(member: member) : const Icon(Icons.person),
        title: Text(member?.name ?? 'Companion'),
        subtitle: Text(
          '${DateTimeUtils.formatTime(shift.startDateTime)} · '
          '${DateTimeUtils.formatDuration(shift.durationMinutes)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push('/shifts/${shift.id}'),
      ),
    );
  }
}
