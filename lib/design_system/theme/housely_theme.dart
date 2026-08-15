import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'housely_tokens.dart';

abstract final class HouselyTheme {
  static ThemeData light() {
    const colors = ColorScheme.light(
      primary: HouselyPalette.violet,
      onPrimary: HouselyPalette.onAccent,
      secondary: HouselyPalette.mint,
      onSecondary: HouselyPalette.canvas,
      error: HouselyPalette.coral,
      onError: HouselyPalette.canvas,
      surface: HouselyPalette.surface,
      onSurface: HouselyPalette.textPrimary,
      outline: HouselyPalette.divider,
      outlineVariant: HouselyPalette.divider,
    );

    final base = ThemeData(
      brightness: Brightness.light,
      colorScheme: colors,
      scaffoldBackgroundColor: HouselyPalette.canvas,
      fontFamily: 'DMSans',
      useMaterial3: true,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme).apply(fontFamily: 'DMSans'),
      dividerColor: HouselyPalette.divider,
      dividerTheme: const DividerThemeData(
        color: HouselyPalette.divider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: HouselyPalette.canvas,
        foregroundColor: HouselyPalette.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: HouselyPalette.textPrimary,
          fontSize: 20,
          height: 1.2,
          fontWeight: FontWeight.w500,
          letterSpacing: -0.4,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(50)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: HouselySpace.lg),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(HouselyRadius.control),
            ),
          ),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
          overlayColor: const WidgetStatePropertyAll(
            HouselyPalette.onAccentPressed,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: HouselyPalette.surface,
        indicatorColor: Colors.transparent,
        indicatorShape: const StadiumBorder(),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? HouselyPalette.violet
                : HouselyPalette.textSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? HouselyPalette.violet
                : HouselyPalette.textSecondary,
            size: 22,
          ),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: HouselyPalette.textSecondary,
        textColor: HouselyPalette.textPrimary,
        minTileHeight: 72,
        horizontalTitleGap: 16,
      ),
      cardTheme: CardThemeData(
        color: HouselyPalette.surface,
        surfaceTintColor: Colors.transparent,
        shadowColor: HouselyPalette.shadow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HouselyRadius.group),
          side: const BorderSide(color: HouselyPalette.divider),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: HouselyPalette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HouselyRadius.feature),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: HouselyPalette.surface,
        modalBackgroundColor: HouselyPalette.surface,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: HouselyPalette.scrim,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: HouselyPalette.surfacePressed,
        contentTextStyle: const TextStyle(color: HouselyPalette.textPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(HouselyRadius.control),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      iconTheme: const IconThemeData(color: HouselyPalette.textSecondary),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: HouselyPalette.violet),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: HouselyPalette.violet,
        foregroundColor: HouselyPalette.onAccent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HouselyPalette.surfaceRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: HouselySpace.md,
          vertical: 15,
        ),
        labelStyle: const TextStyle(color: HouselyPalette.textSecondary),
        hintStyle: const TextStyle(color: HouselyPalette.textTertiary),
        errorStyle: const TextStyle(color: HouselyPalette.coral),
        enabledBorder: _border(HouselyPalette.divider),
        focusedBorder: _border(HouselyPalette.violet, width: 1.5),
        errorBorder: _border(HouselyPalette.coral),
        focusedErrorBorder: _border(HouselyPalette.coral, width: 1.5),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: HouselyPalette.violet,
        scaffoldBackgroundColor: HouselyPalette.canvas,
        barBackgroundColor: HouselyPalette.surface,
        textTheme: CupertinoTextThemeData(
          primaryColor: HouselyPalette.violet,
          textStyle: TextStyle(color: HouselyPalette.textPrimary),
        ),
      ),
    );
  }

  static OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(HouselyRadius.control),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(TextTheme base) => base.copyWith(
    displayLarge: const TextStyle(
      fontSize: 30,
      height: 1.08,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.8,
      color: HouselyPalette.textPrimary,
    ),
    headlineLarge: const TextStyle(
      fontSize: 23,
      height: 1.16,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.55,
      color: HouselyPalette.textPrimary,
    ),
    headlineMedium: const TextStyle(
      fontSize: 21,
      height: 1.18,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.45,
      color: HouselyPalette.textPrimary,
    ),
    titleLarge: const TextStyle(
      fontSize: 17,
      height: 1.24,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.25,
      color: HouselyPalette.textPrimary,
    ),
    titleMedium: const TextStyle(
      fontSize: 15.5,
      height: 1.28,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.15,
      color: HouselyPalette.textPrimary,
    ),
    bodyLarge: const TextStyle(
      fontSize: 15,
      height: 1.42,
      fontWeight: FontWeight.w400,
      color: HouselyPalette.textPrimary,
    ),
    bodyMedium: const TextStyle(
      fontSize: 13.5,
      height: 1.38,
      fontWeight: FontWeight.w400,
      color: HouselyPalette.textSecondary,
    ),
    labelLarge: const TextStyle(
      fontSize: 14.5,
      height: 1.25,
      fontWeight: FontWeight.w500,
      color: HouselyPalette.textPrimary,
    ),
    labelMedium: const TextStyle(
      fontSize: 12,
      height: 1.28,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      color: HouselyPalette.textSecondary,
    ),
  );
}
