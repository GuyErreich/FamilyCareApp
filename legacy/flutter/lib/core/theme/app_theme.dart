import 'package:family_care_scheduler/core/theme/app_motion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Material 3 light and dark themes for the app.
abstract final class AppTheme {
  static const Color seedColor = Color(0xFF5A6B57);

  static ThemeData light() => _baseTheme(_lightScheme);

  static ThemeData dark() => _baseTheme(_darkScheme);

  /// Neutral gray surfaces with muted sage accents — easy on the eyes.
  static const ColorScheme _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF5A6B57),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFD5DBD3),
    onPrimaryContainer: Color(0xFF2A3428),
    secondary: Color(0xFF5C646C),
    onSecondary: Color(0xFFFFFFFF),
    secondaryContainer: Color(0xFFD8DDE3),
    onSecondaryContainer: Color(0xFF2A3038),
    tertiary: Color(0xFF566665),
    onTertiary: Color(0xFFFFFFFF),
    tertiaryContainer: Color(0xFFD3DBDA),
    onTertiaryContainer: Color(0xFF283332),
    error: Color(0xFFB3261E),
    onError: Color(0xFFFFFFFF),
    errorContainer: Color(0xFFF9DEDC),
    onErrorContainer: Color(0xFF410E0B),
    surface: Color(0xFFE3E6EA),
    onSurface: Color(0xFF1C1F23),
    onSurfaceVariant: Color(0xFF4A5058),
    outline: Color(0xFF727880),
    outlineVariant: Color(0xFFB8BFC6),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2D3136),
    onInverseSurface: Color(0xFFF0F2F5),
    inversePrimary: Color(0xFF9AAD94),
    surfaceTint: Color(0xFF5A6B57),
    surfaceContainerLowest: Color(0xFFFAFBFC),
    surfaceContainerLow: Color(0xFFF0F2F5),
    surfaceContainer: Color(0xFFE8EBEF),
    surfaceContainerHigh: Color(0xFFDCE0E5),
    surfaceContainerHighest: Color(0xFFD0D5DB),
  );

  /// Layered charcoal grays with restrained green accents.
  static const ColorScheme _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF9AAD94),
    onPrimary: Color(0xFF1C261A),
    primaryContainer: Color(0xFF323A31),
    onPrimaryContainer: Color(0xFFD0DAD0),
    secondary: Color(0xFFB8BEC6),
    onSecondary: Color(0xFF262A30),
    secondaryContainer: Color(0xFF3A3F47),
    onSecondaryContainer: Color(0xFFD8DDE3),
    tertiary: Color(0xFFADB8B6),
    onTertiary: Color(0xFF232A29),
    tertiaryContainer: Color(0xFF353D3C),
    onTertiaryContainer: Color(0xFFD3DBDA),
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: Color(0xFF121316),
    onSurface: Color(0xFFE4E6EA),
    onSurfaceVariant: Color(0xFFB0B6BE),
    outline: Color(0xFF7E848C),
    outlineVariant: Color(0xFF3D424A),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE4E6EA),
    onInverseSurface: Color(0xFF2D3136),
    inversePrimary: Color(0xFF5A6B57),
    surfaceTint: Color(0xFF9AAD94),
    surfaceContainerLowest: Color(0xFF0A0B0D),
    surfaceContainerLow: Color(0xFF181A1E),
    surfaceContainer: Color(0xFF22252A),
    surfaceContainerHigh: Color(0xFF2C3036),
    surfaceContainerHighest: Color(0xFF383C44),
  );

  static ThemeData _baseTheme(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: isLight ? 0.9 : 0.7),
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: scheme.surfaceContainerLow,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: scheme.shadow.withValues(alpha: isLight ? 0.08 : 0.4),
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        elevation: isLight ? 1 : 0,
        shadowColor: scheme.shadow.withValues(alpha: isLight ? 0.14 : 0.45),
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: isLight ? 0.95 : 0.75),
          ),
        ),
      ),
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          TargetPlatform.android: const FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: const CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: const FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: const CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: const FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      splashFactory: InkSparkle.splashFactory,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          animationDuration: AppMotion.fast,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          side: BorderSide(color: scheme.outlineVariant),
          animationDuration: AppMotion.fast,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          animationDuration: AppMotion.fast,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: isLight ? 3 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: scheme.outlineVariant.withValues(alpha: isLight ? 0.7 : 0.55),
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        tileColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.85),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shadowColor: scheme.shadow.withValues(alpha: isLight ? 0.1 : 0.35),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return scheme.primary.withValues(alpha: 0.1);
          }
          return null;
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        indicatorColor: scheme.primaryContainer.withValues(alpha: 0.85),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelTextStyle: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
        ),
        minWidth: 80,
        groupAlignment: -0.92,
        useIndicator: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: isLight ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        side: BorderSide(color: scheme.outlineVariant),
        selectedColor: scheme.surfaceContainerHighest,
        secondarySelectedColor: scheme.primaryContainer,
        labelStyle: TextStyle(color: scheme.onSurface),
        secondaryLabelStyle: TextStyle(color: scheme.onPrimaryContainer),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.surfaceContainerHighest;
            }
            return scheme.surfaceContainerHigh;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return scheme.primary;
            }
            return scheme.onSurfaceVariant;
          }),
          side: WidgetStateProperty.all(
            BorderSide(color: scheme.outlineVariant),
          ),
        ),
      ),
    );
  }
}
