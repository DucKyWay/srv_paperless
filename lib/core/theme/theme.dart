import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff47672f),
      surfaceTint: Color(0xff336b00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6eb53a),
      onPrimaryContainer: Color(0xff1d4200),
      secondary: Color(0xff4a6634),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffc8eaab),
      onSecondaryContainer: Color(0xff4e6b38),
      tertiary: Color(0xff2b6c02),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffb4ff8a),
      onTertiaryContainer: Color(0xff367812),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfffcf8f8),
      onSurface: Color(0xff1c1b1b),
      onSurfaceVariant: Color(0xff414939),
      outline: Color(0xff717a68),
      outlineVariant: Color(0xffc1cab5),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xff90da5a),
      primaryFixed: Color(0xffabf773),
      onPrimaryFixed: Color(0xff0b2000),
      primaryFixedDim: Color(0xff90da5a),
      onPrimaryFixedVariant: Color(0xff255100),
      secondaryFixed: Color(0xffcbedae),
      onSecondaryFixed: Color(0xff0b2000),
      secondaryFixedDim: Color(0xffb0d194),
      onSecondaryFixedVariant: Color(0xff334e1f),
      tertiaryFixed: Color(0xffacf682),
      onTertiaryFixed: Color(0xff082100),
      tertiaryFixedDim: Color(0xff91d969),
      onTertiaryFixedVariant: Color(0xff1e5200),
      surfaceDim: Color(0xffddd9d9),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xfff1edec),
      surfaceContainerHigh: Color(0xffebe7e7),
      surfaceContainerHighest: Color(0xffe5e2e1),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff47672f),
      surfaceTint: Color(0xff336b00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff3b7c00),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff233d10),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff587542),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff153f00),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3a7c16),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f8),
      onSurface: Color(0xff111111),
      onSurfaceVariant: Color(0xff313929),
      outline: Color(0xff4d5544),
      outlineVariant: Color(0xff67705e),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xff90da5a),
      primaryFixed: Color(0xff3b7c00),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff2d6000),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff587542),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff405c2c),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff3a7c16),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff256100),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c5),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f3f2),
      surfaceContainer: Color(0xffebe7e7),
      surfaceContainerHigh: Color(0xffdfdcdb),
      surfaceContainerHighest: Color(0xffd4d1d0),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff47672f),
      surfaceTint: Color(0xff336b00),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff265300),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff193206),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff355021),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff103300),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff1f5400),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8f8),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff272e20),
      outlineVariant: Color(0xff444c3c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff313030),
      inversePrimary: Color(0xff90da5a),
      primaryFixed: Color(0xff265300),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff193a00),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff355021),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff1f390c),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff1f5400),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff133b00),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b7),
      surfaceBright: Color(0xfffcf8f8),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ef),
      surfaceContainer: Color(0xffe5e2e1),
      surfaceContainerHigh: Color(0xffd7d4d3),
      surfaceContainerHighest: Color(0xffc9c6c5),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffacd28e),
      surfaceTint: Color(0xff90da5a),
      onPrimary: Color(0xff173800),
      primaryContainer: Color(0xff6eb53a),
      onPrimaryContainer: Color(0xff1d4200),
      secondary: Color(0xffb0d194),
      onSecondary: Color(0xff1d370a),
      secondaryContainer: Color(0xff355021),
      onSecondaryContainer: Color(0xffa2c287),
      tertiary: Color(0xffffffff),
      onTertiary: Color(0xff123800),
      tertiaryContainer: Color(0xffacf682),
      onTertiaryContainer: Color(0xff31720a),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff141313),
      onSurface: Color(0xffe5e2e1),
      onSurfaceVariant: Color(0xffc1cab5),
      outline: Color(0xff8b9480),
      outlineVariant: Color(0xff414939),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff336b00),
      primaryFixed: Color(0xffabf773),
      onPrimaryFixed: Color(0xff0b2000),
      primaryFixedDim: Color(0xff90da5a),
      onPrimaryFixedVariant: Color(0xff255100),
      secondaryFixed: Color(0xffcbedae),
      onSecondaryFixed: Color(0xff0b2000),
      secondaryFixedDim: Color(0xffb0d194),
      onSecondaryFixedVariant: Color(0xff334e1f),
      tertiaryFixed: Color(0xffacf682),
      onTertiaryFixed: Color(0xff082100),
      tertiaryFixedDim: Color(0xff91d969),
      onTertiaryFixedVariant: Color(0xff1e5200),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff3a3939),
      surfaceContainerLowest: Color(0xff0e0e0e),
      surfaceContainerLow: Color(0xff1c1b1b),
      surfaceContainer: Color(0xff201f1f),
      surfaceContainerHigh: Color(0xff2a2a2a),
      surfaceContainerHighest: Color(0xff353434),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffadd28e),
      surfaceTint: Color(0xff90da5a),
      onPrimary: Color(0xff112c00),
      primaryContainer: Color(0xff6eb53a),
      onPrimaryContainer: Color(0xff091c00),
      secondary: Color(0xffc5e7a8),
      onSecondary: Color(0xff122b02),
      secondaryContainer: Color(0xff7b9a62),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffffff),
      onTertiary: Color(0xff123800),
      tertiaryContainer: Color(0xffacf682),
      onTertiaryContainer: Color(0xff1e5300),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd7e0ca),
      outline: Color(0xffacb5a1),
      outlineVariant: Color(0xff8b9380),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff255200),
      primaryFixed: Color(0xffabf773),
      onPrimaryFixed: Color(0xff051500),
      primaryFixedDim: Color(0xff90da5a),
      onPrimaryFixedVariant: Color(0xff1b3e00),
      secondaryFixed: Color(0xffcbedae),
      onSecondaryFixed: Color(0xff051500),
      secondaryFixedDim: Color(0xffb0d194),
      onSecondaryFixedVariant: Color(0xff233d10),
      tertiaryFixed: Color(0xffacf682),
      onTertiaryFixed: Color(0xff041500),
      tertiaryFixedDim: Color(0xff91d969),
      onTertiaryFixedVariant: Color(0xff153f00),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff454444),
      surfaceContainerLowest: Color(0xff070707),
      surfaceContainerLow: Color(0xff1e1d1d),
      surfaceContainer: Color(0xff282828),
      surfaceContainerHigh: Color(0xff333232),
      surfaceContainerHighest: Color(0xff3e3d3d),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffacd28e),
      surfaceTint: Color(0xff90da5a),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff8cd657),
      onPrimaryContainer: Color(0xff030e00),
      secondary: Color(0xffd8fbba),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffaccd90),
      onSecondaryContainer: Color(0xff030e00),
      tertiary: Color(0xffffffff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffacf682),
      onTertiaryContainer: Color(0xff0f3100),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff141313),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffeaf3dd),
      outlineVariant: Color(0xffbdc6b1),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe5e2e1),
      inversePrimary: Color(0xff255200),
      primaryFixed: Color(0xffabf773),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff90da5a),
      onPrimaryFixedVariant: Color(0xff051500),
      secondaryFixed: Color(0xffcbedae),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb0d194),
      onSecondaryFixedVariant: Color(0xff051500),
      tertiaryFixed: Color(0xffacf682),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xff91d969),
      onTertiaryFixedVariant: Color(0xff041500),
      surfaceDim: Color(0xff141313),
      surfaceBright: Color(0xff51504f),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1f),
      surfaceContainer: Color(0xff313030),
      surfaceContainerHigh: Color(0xff3c3b3b),
      surfaceContainerHighest: Color(0xff474646),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
     useMaterial3: true,
     brightness: colorScheme.brightness,
     colorScheme: colorScheme,
     textTheme: textTheme.apply(
       bodyColor: colorScheme.onSurface,
       displayColor: colorScheme.onSurface,
     ),
     scaffoldBackgroundColor: colorScheme.surface,
     canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
