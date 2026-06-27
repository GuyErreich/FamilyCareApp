import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Single source of truth for shell navigation destinations.
abstract final class AppNavigationDestinations {
  static const List<AppNavDestination> all = [
    AppNavDestination(
      label: 'Today',
      icon: Icons.today_outlined,
      selectedIcon: Icons.today,
      tooltip: 'Today\'s schedule',
    ),
    AppNavDestination(
      label: 'Plan',
      icon: Icons.edit_calendar_outlined,
      selectedIcon: Icons.edit_calendar,
      tooltip: 'Plan and schedule shifts',
    ),
    AppNavDestination(
      label: 'Family',
      icon: Icons.family_restroom_outlined,
      selectedIcon: Icons.family_restroom,
      tooltip: 'Family members',
    ),
    AppNavDestination(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings,
      tooltip: 'App settings',
    ),
  ];
}

/// Metadata for one primary shell tab.
class AppNavDestination {
  const AppNavDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.tooltip,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String tooltip;
}

/// Polished bottom bar and rail for [StatefulNavigationShell].
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  void _select(int index) {
    if (index != selectedIndex) {
      HapticFeedback.lightImpact();
    }
    onDestinationSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLight = scheme.brightness == Brightness.light;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: scheme.outlineVariant.withValues(alpha: isLight ? 0.9 : 0.65),
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(alpha: isLight ? 0.08 : 0.35),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: NavigationBar(
            selectedIndex: selectedIndex,
            onDestinationSelected: _select,
            animationDuration: const Duration(milliseconds: 300),
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 68,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              for (final dest in AppNavigationDestinations.all)
                NavigationDestination(
                  icon: Tooltip(
                    message: dest.tooltip,
                    child: Icon(dest.icon),
                  ),
                  selectedIcon: Tooltip(
                    message: dest.tooltip,
                    child: Icon(dest.selectedIcon),
                  ),
                  label: dest.label,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tablet sidebar navigation with branded header.
class AppNavigationRail extends StatelessWidget {
  const AppNavigationRail({
    required this.selectedIndex,
    required this.onDestinationSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  void _select(int index) {
    if (index != selectedIndex) {
      HapticFeedback.lightImpact();
    }
    onDestinationSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: _select,
      labelType: NavigationRailLabelType.all,
      groupAlignment: -0.92,
      minWidth: 80,
      useIndicator: true,
      leading: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        child: CircleAvatar(
          radius: 22,
          backgroundColor: scheme.primaryContainer,
          child: Icon(Icons.favorite, color: scheme.onPrimaryContainer, size: 22),
        ),
      ),
      destinations: [
        for (final dest in AppNavigationDestinations.all)
          NavigationRailDestination(
            icon: Tooltip(message: dest.tooltip, child: Icon(dest.icon)),
            selectedIcon:
                Tooltip(message: dest.tooltip, child: Icon(dest.selectedIcon)),
            label: Text(dest.label),
          ),
      ],
    );
  }
}
