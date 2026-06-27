import 'package:flutter/material.dart';

/// Extension for responsive layout helpers.
extension BuildContextX on BuildContext {
  bool get isTablet => MediaQuery.sizeOf(this).width >= 600;

  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;
}
