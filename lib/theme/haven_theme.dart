import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The Haven palette, lifted directly from the design tokens.
class HavenColors {
  // Core
  static const ink = Color(0xFF3A352F);
  static const sage = Color(0xFF7C9885);
  static const sageDeep = Color(0xFF6C8A72);

  // State / mood accents
  static const clay = Color(0xFFC08A72);
  static const blue = Color(0xFF8198AD);
  static const dusk = Color(0xFF9B8AA8);
  static const slate = Color(0xFF7A8893);
  static const amber = Color(0xFFBCA06A);

  // Surfaces
  static const cream = Color(0xFFF7F3EC); // app background
  static const card = Color(0xFFFDFBF7); // raised cards / inputs
  static const greenTint = Color(0xFFEEF3EE); // gentle highlight panels
  static const drawerBg = Color(0xFFF4EFE5);

  // Borders / hairlines
  static const border = Color(0xFFECE5D8);
  static const borderSoft = Color(0xFFE3DCCD);
  static const borderWarm = Color(0xFFE6DFD1);
  static const track = Color(0xFFE9E2D4); // slider / dot tracks

  // Muted text
  static const muted = Color(0xFF8C857B);
  static const muted2 = Color(0xFFA59B8C);
  static const faint = Color(0xFFB8B0A4);
  static const faint2 = Color(0xFFB3AA9B);
  static const disabledBg = Color(0xFFE1DACD);
}

/// Newsreader — the soft serif used for headings, numbers, and quotes.
TextStyle news({
  double size = 16,
  FontWeight weight = FontWeight.w300,
  Color color = HavenColors.ink,
  double? height,
  bool italic = false,
  double? letterSpacing,
}) {
  return GoogleFonts.newsreader(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    letterSpacing: letterSpacing,
  );
}

/// Hanken Grotesk — the workhorse sans for body, labels, and buttons.
TextStyle hank({
  double size = 14,
  FontWeight weight = FontWeight.w400,
  Color color = HavenColors.ink,
  double? height,
  double? letterSpacing,
}) {
  return GoogleFonts.hankenGrotesk(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );
}

/// An uppercase eyebrow label (".12em letter-spacing, muted").
TextStyle eyebrow({Color color = HavenColors.muted2, double size = 12}) {
  return hank(
    size: size,
    weight: FontWeight.w600,
    color: color,
    letterSpacing: size * 0.1,
  );
}

class HavenTheme {
  static ThemeData build() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: HavenColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: HavenColors.sageDeep,
        primary: HavenColors.sageDeep,
        surface: HavenColors.cream,
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.hankenGroteskTextTheme(base.textTheme),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
