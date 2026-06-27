import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/core/utils/date_time_utils.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/dashboard/domain/usecases/get_today_schedule_use_case.dart';
import 'package:family_care_scheduler/features/dashboard/presentation/widgets/today_shifts_view.dart';
import 'package:family_care_scheduler/features/family/presentation/providers/family_providers.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_member_filter.dart';
import 'package:family_care_scheduler/features/schedule/presentation/plan_view_mode_provider.dart';
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

/// Today tab — read-only shift list (no scheduling).
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = DateTimeUtils.dateOnly(DateTime.now());
    final shiftsAsync = ref.watch(todayShiftsProvider);
    final members = ref.watch(familyMembersProvider).valueOrNull ?? [];
    final memberFilter = ref.watch(scheduleMemberFilterProvider);

    return AppScaffold(
      title: 'Today',
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your shifts for today',
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
                final visible = ScheduleMemberFilterUtils.filterShifts(
                  shifts: shifts,
                  filter: memberFilter,
                  currentUserId:
                      ref.watch(authStateProvider).valueOrNull?.id,
                );
                final schedule = const GetTodayScheduleUseCase().call(visible);

                return TodayShiftsView(
                  schedule: schedule,
                  members: members,
                  onShiftTap: (shift) => context.push('/shifts/${shift.id}'),
                  onOpenOverview: () {
                    openPlanForDate(ref, today);
                    context.go(AppRoutes.calendar);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
