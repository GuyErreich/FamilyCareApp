import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Per-user or per-family application settings.
@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    required String id,
  @Default(<Duration>[]) List<Duration> defaultReminderOffsets,
    @Default(ThemeMode.system) ThemeMode themeMode,
    String? locale,
  }) = _AppSettings;
}
