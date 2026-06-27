import 'package:family_care_scheduler/core/router/page_transitions.dart';
import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/features/auth/domain/entities/app_user.dart';
import 'package:family_care_scheduler/features/auth/presentation/pages/login_page.dart';
import 'package:family_care_scheduler/features/auth/presentation/pages/onboarding_page.dart';
import 'package:family_care_scheduler/features/auth/presentation/pages/register_page.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/calendar/presentation/pages/calendar_page.dart';
import 'package:family_care_scheduler/features/calendar/presentation/pages/day_schedule_page.dart';
import 'package:family_care_scheduler/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:family_care_scheduler/features/family/presentation/pages/family_members_page.dart';
import 'package:family_care_scheduler/features/settings/presentation/pages/coverage_fallback_page.dart';
import 'package:family_care_scheduler/features/settings/presentation/pages/settings_page.dart';
import 'package:family_care_scheduler/features/shifts/presentation/pages/create_shift_page.dart';
import 'package:family_care_scheduler/features/shifts/presentation/pages/shift_details_page.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _AuthRefreshListenable(ref);

  final router = GoRouter(
    initialLocation: AppRoutes.dashboard,
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final user = ref.read(authStateProvider).valueOrNull;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (user == null) {
        return isAuthRoute ? null : AppRoutes.login;
      }

      if (user.familyId == null || user.familyId!.isEmpty) {
        return state.matchedLocation == AppRoutes.onboarding
            ? null
            : AppRoutes.onboarding;
      }

      if (isAuthRoute || state.matchedLocation == AppRoutes.onboarding) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.calendar,
                builder: (context, state) => const CalendarPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.family,
                builder: (context, state) => const FamilyMembersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (context, state) => const SettingsPage(),
                routes: [
                  GoRoute(
                    path: 'coverage-fallback',
                    builder: (context, state) => const CoverageFallbackPage(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.daySchedule,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return fadeSlidePage(
            state: state,
            child: ShiftsViewPage(
              day: extra?['day'] as DateTime? ?? DateTime.now(),
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.createShift,
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return fadeSlidePage(
            state: state,
            child: CreateShiftPage(
              initialDate: extra?['date'] as DateTime?,
              initialUserId: extra?['userId'] as String?,
              initialStartHour: extra?['startHour'] as int?,
              initialStartMinute: extra?['startMinute'] as int?,
              initialDurationMinutes: extra?['durationMinutes'] as int?,
            ),
          );
        },
      ),
      GoRoute(
        path: '/shifts/:id',
        pageBuilder: (context, state) => sharedAxisPage(
          state: state,
          child: ShiftDetailsPage(shiftId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/shifts/:id/edit',
        pageBuilder: (context, state) => fadeSlidePage(
          state: state,
          child: CreateShiftPage(
            shiftId: state.pathParameters['id'],
          ),
        ),
      ),
    ],
  );

  ref.onDispose(() {
    refreshListenable.dispose();
    router.dispose();
  });

  return router;
});

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable(this._ref) {
    _subscription = _ref.listen(authStateProvider, (_, _) => notifyListeners());
  }

  final Ref _ref;
  late final ProviderSubscription<AsyncValue<AppUser?>> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
