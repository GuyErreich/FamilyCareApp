import 'package:flutter/material.dart';

/// Named routes for [GoRouter].
abstract final class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String calendar = '/calendar';
  static const String family = '/family';
  static const String settings = '/settings';
  static const String createShift = '/shifts/create';
  static const String shiftDetails = '/shifts/:id';
  static const String editShift = '/shifts/:id/edit';
}

/// Extension for responsive layout helpers.
extension BuildContextX on BuildContext {
  bool get isTablet => MediaQuery.sizeOf(this).width >= 600;

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;
}
