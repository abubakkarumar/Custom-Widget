import 'package:flutter/material.dart';

///Background Color you can change the color of the background
class ThemeBackgroundColor {
  static Color getBackgroundColor(BuildContext context) {
    return Theme.of(context).colorScheme.surface;
  }
}

class ThemeTextOneColor {
  static Color getTextOneColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurfaceVariant;
  }
}

class ThemeTextColor {
  static Color getTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
}

class ThemePrimaryColor {
  static Color getPrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primary;
  }
}

class ThemeInversePrimaryColor {
  static Color getInversePrimaryColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryFixedDim;
  }
}

class ThemeButtonColor {
  static Color getButtonColor(BuildContext context) {
    return Theme.of(context).colorScheme.primaryFixed;
  }
}

class ThemeButtonTextColor {
  static Color getButtonTextColor(BuildContext context) {
    return Theme.of(context).colorScheme.onPrimary;
  }
}

class ThemeOutLineColor {
  static Color getOutLineColor(BuildContext context) {
    return Theme.of(context).colorScheme.outline;
  }
}

class ThemeSurfaceContainerLowColor {
  static Color getSurfaceContainerLowColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainerLow;
  }
}

class ThemeTextFormFillColor {
  static Color getTextFormFillColor(BuildContext context) {
    return Theme.of(context).colorScheme.surfaceContainer;
  }
}

class ThemeOnSurfaceColor {
  static Color getOnSurfaceColor(BuildContext context) {
    return Theme.of(context).colorScheme.onSurface;
  }
}

class ThemeNoteColor {
  static Color getNoteColorColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiaryFixed;
  }
}

class ThemeOnSecondary {
  static Color getOnSecondary(BuildContext context) {
    return Theme.of(context).colorScheme.secondary;
  }
}
