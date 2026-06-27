import 'package:family_care_scheduler/core/router/app_routes.dart';
import 'package:family_care_scheduler/core/constants/app_constants.dart';
import 'package:family_care_scheduler/core/errors/result.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_debug.dart';
import 'package:family_care_scheduler/features/google_calendar/domain/google_calendar_service.dart';
import 'package:family_care_scheduler/features/notifications/domain/fcm_service.dart';
import 'package:family_care_scheduler/features/schedule/domain/schedule_constants.dart';
import 'package:family_care_scheduler/features/schedule/presentation/schedule_preferences.dart';
import 'package:family_care_scheduler/features/settings/presentation/providers/settings_provider.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  var _isConnectingCalendar = false;
  var _isSavingScheduleView = false;

  Future<void> _setScheduleDaysShowed(int days) async {
    setState(() => _isSavingScheduleView = true);
    final result = await updateScheduleDaysShowed(ref, days);
    if (!mounted) return;

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Default schedule view set to ${scheduleDaysShowedLabel(days)}.',
            ),
          ),
        );
      case Error(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failure.message)),
        );
    }

    if (mounted) setState(() => _isSavingScheduleView = false);
  }

  Future<void> _connectGoogleCalendar() async {
    setState(() => _isConnectingCalendar = true);

    final result = await ref.read(googleCalendarServiceProvider).connect();
    if (!mounted) return;

    switch (result) {
      case Success():
        final user = ref.read(authStateProvider).valueOrNull;
        if (user != null && !user.googleCalendarConnected) {
          final updateResult = await ref.read(authRepositoryProvider).updateUser(
                user.copyWith(googleCalendarConnected: true),
              );
          switch (updateResult) {
            case Error(:final failure):
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Calendar access granted, but status could not be saved: '
                      '${failure.message}',
                    ),
                  ),
                );
              }
            case Success():
              break;
          }
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Google Calendar connected.'),
            ),
          );
        }
      case Error(:final failure):
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
        googleCalendarDebug('Settings connect failed', error: failure.message);
    }

    if (mounted) setState(() => _isConnectingCalendar = false);
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final user = ref.watch(authStateProvider).valueOrNull;
    final calendarConnected = user?.googleCalendarConnected ?? false;
    final daysShowed = ref.watch(scheduleDaysShowedProvider);

    return AppScaffold(
      title: 'Settings',
      body: ListView(
        children: [
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(themeMode.name),
            trailing: DropdownButton<ThemeMode>(
              value: themeMode,
              items: ThemeMode.values
                  .map(
                    (mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(mode.name),
                    ),
                  )
                  .toList(),
              onChanged: (mode) {
                if (mode != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(mode);
                }
              },
            ),
          ),
          ListTile(
            title: const Text('Default schedule view'),
            subtitle: Text(
              '${scheduleDaysShowedLabel(daysShowed)} timeline in Plan',
            ),
            trailing: _isSavingScheduleView
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : DropdownButton<int>(
                    value: daysShowed,
                    underline: const SizedBox.shrink(),
                    items: ScheduleConstants.allowedDaysShowed
                        .map(
                          (days) => DropdownMenuItem(
                            value: days,
                            child: Text(scheduleDaysShowedLabel(days)),
                          ),
                        )
                        .toList(),
                    onChanged: (days) {
                      if (days != null) _setScheduleDaysShowed(days);
                    },
                  ),
          ),
          ListTile(
            leading: const Icon(Icons.calendar_month),
            title: const Text('Google Calendar'),
            subtitle: Text(
              calendarConnected
                  ? 'Connected — you can add shifts to your calendar'
                  : 'Connect to add companion shifts to your calendar',
            ),
            trailing: calendarConnected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : _isConnectingCalendar
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        onPressed: _connectGoogleCalendar,
                        child: const Text('Connect'),
                      ),
          ),
          const ListTile(
            title: Text('Default reminders'),
            subtitle: Text('1 day, 1 hour, and 15 minutes before'),
          ),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Coverage fallback'),
            subtitle: const Text(
              'Who steps in when someone can\'t make a shift',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(AppRoutes.coverageFallback),
          ),
          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text('Shift updates from your family'),
            value: true,
            onChanged: (_) {},
          ),
          ListTile(
            title: const Text('Sign out'),
            leading: const Icon(Icons.logout),
            onTap: () async {
              await ref.read(fcmServiceProvider).clearToken();
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
          const ListTile(
            title: Text('About'),
            subtitle: Text(AppConstants.appName),
          ),
        ],
      ),
    );
  }
}
