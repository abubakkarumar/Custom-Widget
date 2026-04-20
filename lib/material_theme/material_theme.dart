import 'package:flutter/material.dart';

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      surface: Color(0xFFFFFFFF),
      surfaceContainer: Color(0xFFEDEDF0),
      surfaceContainerHigh: Color(0xFFEDEDF0),
      surfaceContainerLow: Color(0xFF3D3D50),
      secondary: Color(0xFF13131B),
      outline: Color(0xFFD2D3DB),
      primary: Color(0xFF6548EC),
      onPrimary: Color(0xFFFFFFFF),
      primaryFixedDim: Color(0xFF007FFF),
      primaryFixed: Color(0xFFBF00FF),
      onSurface: Color(0xFF0A0A0C),
      onSurfaceVariant: Color(0xFF7B7C87),
      error: Color(0xFFF23643),
      tertiary: Color(0xFF00AF89),
      scrim: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
      onError: Color(0xffFFFFFF),
      tertiaryFixed:  Color(0xFFeaf0f8)
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,

      surface: Color(0xFF020209),
      surfaceContainer: Color(0xFF13131B),
      surfaceContainerHigh: Color(0xFFEDEDF0),
      surfaceContainerLow: Color(0xFF3D3D50),
      secondary: Color(0xFF13131B),
      outline: Color(0xFF272738),
      primary: Color(0xFF6548EC),
      onPrimary: Color(0xFFFFFFFF),
      primaryFixedDim: Color(0xFF007FFF),
      primaryFixed: Color(0xFFBF00FF),
      onSurface: Color(0xFFF6F6F8),
      onSurfaceVariant: Color(0xFF9A9EB5),
      error: Color(0xFFF23643),
      tertiary: Color(0xFF00AF89),
      scrim: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
      onError: Color(0xffFFFFFF),
      tertiaryFixed: Color(0xFF030814)
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),

    canvasColor: colorScheme.surface,

    splashFactory: NoSplash.splashFactory,
    splashColor: Colors.transparent,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,

    // ✅ FilledButton theme applied globally
    // filledButtonTheme: FilledButtonThemeData(
    //   style: ButtonStyle(
    //     backgroundColor: WidgetStateProperty.all(colorScheme.primary),
    //     foregroundColor: WidgetStateProperty.all(colorScheme.onPrimary),
    //     textStyle: WidgetStateProperty.all(textTheme.labelLarge),
    //     shape: WidgetStateProperty.all(
    //       RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(100.sp),
    //       ),
    //     ),
    //     padding: WidgetStateProperty.all(
    //       const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    //     ),
    //     elevation: WidgetStateProperty.all(0),
    //   ),
    // ),
    //
    // outlinedButtonTheme: OutlinedButtonThemeData(
    //   style: OutlinedButton.styleFrom(
    //     side: BorderSide(color: colorScheme.primary), // Light grey stroke
    //     textStyle: TextStyle(
    //         fontSize: 16.px,
    //         fontWeight: FontWeight.bold,
    //         color: colorScheme.primary
    //     ),
    //   ),
    // ),
  );
}
