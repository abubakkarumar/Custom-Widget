import 'package:flutter/material.dart';
TextTheme createTextTheme(
    BuildContext context, TextTheme fontTheme) {
  TextTheme bodyTextTheme = fontTheme;
  TextTheme displayTextTheme = fontTheme;
  TextTheme textTheme = displayTextTheme.copyWith(
    displayLarge: bodyTextTheme.displayLarge,
    displayMedium: bodyTextTheme.displayMedium,
    displaySmall: bodyTextTheme.displaySmall,
    headlineLarge: bodyTextTheme.headlineLarge,
    headlineMedium: bodyTextTheme.headlineMedium,
    headlineSmall: bodyTextTheme.headlineSmall,
    titleLarge: bodyTextTheme.titleLarge,
    titleMedium: bodyTextTheme.titleMedium,
    titleSmall: bodyTextTheme.titleSmall,
    bodyLarge: bodyTextTheme.bodyLarge,
    bodyMedium: bodyTextTheme.bodyMedium,
    bodySmall: bodyTextTheme.bodySmall,
    labelLarge: bodyTextTheme.labelLarge,
    labelMedium: bodyTextTheme.labelMedium,
    labelSmall: bodyTextTheme.labelSmall,
  );
  return textTheme;
}
