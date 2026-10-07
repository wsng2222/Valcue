import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// App Theme Extension for semantic color tokens
/// Provides iOS-like semantic colors that adapt to light/dark themes
class AppColors extends ThemeExtension<AppColors> {
  final Color surfaceElevated;
  final Color border;
  final Color mutedText;
  final Color danger;
  final Color dangerText;

  /// Grouped fill behind chips, stat panels and interval rows.
  final Color subtle;

  /// Faint primary wash behind header icons and secondary red actions.
  final Color tint;

  /// Track color for segmented controls, progress bars and rings.
  final Color track;

  /// Near-background fill for form rows inside sheets.
  final Color soft;

  const AppColors({
    required this.surfaceElevated,
    required this.border,
    required this.mutedText,
    required this.danger,
    required this.dangerText,
    required this.subtle,
    required this.tint,
    required this.track,
    required this.soft,
  });

  @override
  AppColors copyWith({
    Color? surfaceElevated,
    Color? border,
    Color? mutedText,
    Color? danger,
    Color? dangerText,
    Color? subtle,
    Color? tint,
    Color? track,
    Color? soft,
  }) {
    return AppColors(
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      mutedText: mutedText ?? this.mutedText,
      danger: danger ?? this.danger,
      dangerText: dangerText ?? this.dangerText,
      subtle: subtle ?? this.subtle,
      tint: tint ?? this.tint,
      track: track ?? this.track,
      soft: soft ?? this.soft,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerText: Color.lerp(dangerText, other.dangerText, t)!,
      subtle: Color.lerp(subtle, other.subtle, t)!,
      tint: Color.lerp(tint, other.tint, t)!,
      track: Color.lerp(track, other.track, t)!,
      soft: Color.lerp(soft, other.soft, t)!,
    );
  }
}

class AppTheme {
  /// Shared corner radius for primary/secondary CTA buttons (ElevatedButton,
  /// AdaptiveButton, etc.) across the app, so buttons look consistent from
  /// screen to screen regardless of their width or height.
  static const double buttonRadius = 999;

  /// AppBar system overlay styles that only set icon brightness, leaving
  /// [SystemUiOverlayStyle.statusBarColor], [systemNavigationBarColor], and
  /// [systemNavigationBarDividerColor] at their default `null`. The built-in
  /// [SystemUiOverlayStyle.light]/[.dark] presets Flutter would otherwise
  /// infer per-AppBar set explicit colors, which triggers the deprecated
  /// Window.setStatusBarColor/setNavigationBarColor/setNavigationBarDividerColor
  /// calls Play Console flags on Android 15 (Window.setDecorFitsSystemWindows(false)
  /// in MainActivity.hideSystemUI already makes the app draw edge-to-edge, so no
  /// color is needed here).
  static const SystemUiOverlayStyle _lightAppBarOverlayStyle =
      SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarIconBrightness: Brightness.dark,
  );
  static const SystemUiOverlayStyle _darkAppBarOverlayStyle =
      SystemUiOverlayStyle(
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarIconBrightness: Brightness.light,
  );

  /// Bundled with the app (see pubspec `fonts:`), in exactly the weights the
  /// design uses - 400/700/800. Referencing it by name means no network
  /// round-trip, and any stray `w900` in the codebase resolves to the
  /// nearest bundled face (800) rather than rendering heavier than the design.
  static const String latinFontFamily = 'Lato';

  /// The face that carries a locale's own script. Latin locales use the
  /// bundled Lato; the rest still come from google_fonts at runtime.
  static String primaryFontFamilyFor(Locale locale) {
    return switch (locale.languageCode) {
      'ar' => GoogleFonts.notoSansArabic().fontFamily!,
      'th' => GoogleFonts.notoSansThai().fontFamily!,
      'ko' => GoogleFonts.notoSansKr().fontFamily!,
      'ja' => GoogleFonts.notoSansJp().fontFamily!,
      'zh' => GoogleFonts.notoSansSc().fontFamily!,
      _ => latinFontFamily,
    };
  }

  static List<String> _fallbacksFor(Locale locale) {
    // Latin digits and app-chrome glyphs still come from Lato even in a
    // non-Latin locale, so it stays in the chain behind the script face.
    return switch (locale.languageCode) {
      'ar' || 'th' || 'ko' || 'ja' || 'zh' => [latinFontFamily],
      _ => const <String>[],
    };
  }

  /// iOS draws a lot of this app through Cupertino widgets, and Cupertino
  /// ignores the Material text theme completely. Without a text theme here
  /// every Cupertino-drawn label renders in SF Pro no matter what the
  /// Material theme says, which is the single biggest reason the app did not
  /// look like the design on an iPhone.
  static CupertinoThemeData cupertinoThemeFor(
    Brightness brightness,
    Locale locale,
  ) {
    final family = primaryFontFamilyFor(locale);
    final fallbacks = _fallbacksFor(locale);
    final base = brightness == Brightness.dark ? Colors.white : Colors.black87;

    TextStyle styled(
      double size,
      FontWeight weight, {
      Color? color,
      double? letterSpacing,
    }) {
      return TextStyle(
        fontFamily: family,
        fontFamilyFallback: fallbacks,
        fontSize: size,
        fontWeight: weight,
        color: color ?? base,
        letterSpacing: letterSpacing,
      );
    }

    return CupertinoThemeData(
      brightness: brightness,
      primaryColor: Colors.red,
      textTheme: CupertinoTextThemeData(
        primaryColor: Colors.red,
        textStyle: styled(16, FontWeight.w400, letterSpacing: -0.2),
        actionTextStyle: styled(16, FontWeight.w700, color: Colors.red),
        tabLabelTextStyle: styled(12, FontWeight.w700, letterSpacing: -0.1),
        navTitleTextStyle: styled(17, FontWeight.w700, letterSpacing: -0.3),
        navLargeTitleTextStyle:
            styled(32, FontWeight.w800, letterSpacing: -0.8),
        navActionTextStyle: styled(16, FontWeight.w700, color: Colors.red),
        pickerTextStyle: styled(21, FontWeight.w400),
        dateTimePickerTextStyle: styled(21, FontWeight.w400),
      ),
    );
  }

  static ThemeData forLocale(ThemeData theme, Locale locale) {
    final primaryFamily = primaryFontFamilyFor(locale);
    final fallbacks = _fallbacksFor(locale);

    // ThemeData has no fontFamily field of its own - the constructor argument
    // is sugar that applies the family to these two text themes - so applying
    // them here is the whole job.
    return theme.copyWith(
      textTheme: theme.textTheme.apply(
        fontFamily: primaryFamily,
        fontFamilyFallback: fallbacks,
      ),
      primaryTextTheme: theme.primaryTextTheme.apply(
        fontFamily: primaryFamily,
        fontFamilyFallback: fallbacks,
      ),
    );
  }

  // Light Theme
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.light,
    ).copyWith(
      primary: Colors.red,
      secondary: Colors.red.shade700,
      error: Colors.red,
      surface: Colors.white,
      onSurface: Colors.black,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    textTheme: _buildTextTheme(Brightness.light),
    fontFamily: latinFontFamily,
    fontFamilyFallback: [
      GoogleFonts.notoSansArabic().fontFamily!,
      GoogleFonts.notoSansThai().fontFamily!,
      GoogleFonts.notoSansKr().fontFamily!,
      GoogleFonts.notoSansJp().fontFamily!,
      GoogleFonts.notoSansSc().fontFamily!,
      GoogleFonts.notoSansTc().fontFamily!,
    ],
    iconTheme: const IconThemeData(
      color: Colors.black87,
      size: 24,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.black87),
      systemOverlayStyle: _lightAppBarOverlayStyle,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.black87,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade200,
        disabledForegroundColor: const Color(0xFF8E8E93),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        elevation: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.black87,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(
        surfaceElevated: Color(0xFFFFFFFF),
        border: Color(0xFFEEEEEE),
        mutedText: Color(0xFF8E8E93),
        danger: Color(0xFFFF3B30),
        dangerText: Color(0xFFFF3B30),
        subtle: Color(0xFFF2F2F7),
        tint: Color(0xFFFFEBEE),
        track: Color(0x1F767680),
        soft: Color(0xFFFCFBFB),
      ),
    ],
  );

  // Dark Theme
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.red,
      brightness: Brightness.dark,
    ).copyWith(
      primary: Colors.red.shade400,
      secondary: Colors.red.shade300,
      error: Colors.red.shade400,
      surface: const Color(0xFF1C1C1E),
      onSurface: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF000000),
    textTheme: _buildTextTheme(Brightness.dark),
    fontFamily: latinFontFamily,
    fontFamilyFallback: [
      GoogleFonts.notoSansArabic().fontFamily!,
      GoogleFonts.notoSansThai().fontFamily!,
      GoogleFonts.notoSansKr().fontFamily!,
      GoogleFonts.notoSansJp().fontFamily!,
      GoogleFonts.notoSansSc().fontFamily!,
      GoogleFonts.notoSansTc().fontFamily!,
    ],
    iconTheme: const IconThemeData(
      color: Colors.white,
      size: 24,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1C1E),
      foregroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Colors.white),
      systemOverlayStyle: _darkAppBarOverlayStyle,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.transparent,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white70,
      elevation: 0,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red.shade400,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.white.withValues(alpha: 0.1),
        disabledForegroundColor: const Color(0xFF8E8E93),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
        ),
        elevation: 0,
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1C1C1E),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
      ),
      surfaceTintColor: Colors.transparent,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF1C1C1E),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 0,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: Colors.white.withValues(alpha: 0.1),
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: false,
      border: InputBorder.none,
      enabledBorder: InputBorder.none,
      focusedBorder: InputBorder.none,
      errorBorder: InputBorder.none,
      focusedErrorBorder: InputBorder.none,
      contentPadding: EdgeInsets.zero,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF2C2C2E),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      behavior: SnackBarBehavior.floating,
    ),
    extensions: const <ThemeExtension<dynamic>>[
      AppColors(
        surfaceElevated: Color(0xFF2C2C2E),
        border: Color(0x1AFFFFFF),
        mutedText: Color(0xFF8E8E93),
        danger: Color(0xFFFF453A),
        dangerText: Color(0xFFFF6961),
        subtle: Color(0xFF2C2C2E),
        tint: Color(0x2EEF5350),
        track: Color(0x3D767680),
        soft: Color(0xFF242426),
      ),
    ],
  );

  /// Type scale measured off the design prototype. The prototype uses only
  /// 700 and 800 - it never uses 900 - so headings sit at 800, labels at 700
  /// and running text at 400. The app previously set almost every slot to
  /// 900, which is what made every screen read heavier than the design.
  static TextTheme _buildTextTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white : Colors.black87;

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 64,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -2.0,
      ),
      displayMedium: TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -1.5,
      ),
      displaySmall: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -1.0,
      ),
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        color: baseColor,
        letterSpacing: -0.5,
      ),
      titleMedium: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.3,
      ),
      titleSmall: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.3,
      ),
      bodyLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: -0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: baseColor,
        letterSpacing: -0.2,
      ),
      bodySmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? Colors.white70 : Colors.black54,
        letterSpacing: -0.2,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.3,
      ),
      labelMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: baseColor,
        letterSpacing: -0.2,
      ),
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white60 : Colors.black54,
        letterSpacing: -0.1,
      ),
    );
  }
}

/// Helper extension to easily access AppColors from context
extension AppColorsExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}
