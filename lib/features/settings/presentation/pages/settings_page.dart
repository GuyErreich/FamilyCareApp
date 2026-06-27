import 'package:family_care_scheduler/core/constants/app_constants.dart';
import 'package:family_care_scheduler/core/providers/repository_providers.dart';
import 'package:family_care_scheduler/features/auth/presentation/providers/auth_providers.dart';
import 'package:family_care_scheduler/features/notifications/domain/fcm_service.dart';
import 'package:family_care_scheduler/features/settings/presentation/providers/settings_provider.dart';
import 'package:family_care_scheduler/shared/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

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
          const ListTile(
            title: Text('Default reminders'),
            subtitle: Text('1 day, 1 hour, and 15 minutes before'),
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
            onPressed: () async {
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
