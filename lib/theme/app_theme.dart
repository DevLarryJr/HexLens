import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFFCF9F2);

  static const glassHeader = Color(0xD9FCF9F2);
  static const glassBar = Color(0xE6FCF9F2);
  static const glassSolid = Color(0xF2FCF9F2);
  static const surface = Colors.white;

  static const surfaceFaded = Color(0xCCFFFFFF);
  static const surfaceLow = Color(0xFFF6F3EC);
  static const surfaceContainer = Color(0xFFF1EEE7);
  static const surfaceHigh = Color(0xFFEBE8E1);
  static const surfaceHighest = Color(0xFFE5E2DB);

  static const surfaceHighFaded = Color(0x99EBE8E1);

  static const surfaceHighGhost = Color(0x66EBE8E1);

  static const surfaceHighestFaded = Color(0x99E5E2DB);

  static const onDarkFaint = Color(0x33E5E2DB);

  static const onDarkSoft = Color(0x4DE5E2DB);

  static const onSurface = Color(0xFF1C1C18);
  static const onSurfaceVariant = Color(0xFF444748);
  static const outline = Color(0xFF616565);
  static const outlineVariant = Color(0xFFC4C7C7);

  static const outlineFaint = Color(0x4DC4C7C7);

  static const scrim = Color(0xCC000000);
  static const scrimSoft = Color(0xB3000000);

  static const barrier = Color(0x99363636);
  static const barrierStrong = Color(0xB3363636);

  static const accentBorder = Color(0xFFF1B5AA);

  static const disabled = Color(0x66444748);

  static const neutralDot = Color(0xFF5F5E5E);
  static const muted = Color(0xFF62686F);

  static const primary = Colors.black;
  static const ink = Color(0xFF1C1B1B);

  static const accent = Color(0xFFB61800);
  static const accentBright = Color(0xFFDB351A);

  static const accentOverlay = Color(0x22DB351A);

  static const onAccentBright = Color(0xFFFFFBFF);
  static const accentContainer = Color(0xFFFFDAD3);

  static const accentTint = Color(0x80FFDAD3);

  static const accentFaint = Color(0x26B61800);

  static const accentWash = Color(0x1AB61800);
  static const onAccentContainer = Color(0xFF3F0300);

  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  static const errorTag = Color(0xFFFFB4AB);

  static const errorWash = Color(0xFFFFE9E5);

  static const darkMuted = Color(0xFF858383);

  static const neutralContainer = Color(0xFFDDE3EB);
  static const onNeutralContainer = Color(0xFF161C22);

  static const graphite = Color(0xFF3A3A3A);

  static const charcoal = Color(0xFF333333);

  static const surfaceDim = Color(0xFFDCDAD3);

  static const success = Color(0xFF16A34A);

  static const whatsapp = Color(0xFF22A55B);
  static const successDark = Color(0xFF166534);

  static const successContainer = Color(0xFFE6F4E7);
}

class AppRadius {
  static const xs = BorderRadius.all(Radius.circular(2));

  static const sm = BorderRadius.all(Radius.circular(4));

  static const md = BorderRadius.all(Radius.circular(8));

  static const lg = BorderRadius.all(Radius.circular(12));
}

class AppFilters {
  static const grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);
}

class AppShadows {
  static const soft = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 1),
  ];

  static const hairline = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  static const medium = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
  ];

  static const large = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 20), blurRadius: 25, spreadRadius: -5),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 8), blurRadius: 10, spreadRadius: -6),
  ];

  static const sheetActions = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, -2), blurRadius: 8),
  ];

  static const bottomBar = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, -4), blurRadius: 16),
  ];

  static const header = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 8),
  ];
}

class AppText {
  static const tamanoMinimo = 12.0;

  static double _tamano(double size) => size < tamanoMinimo ? tamanoMinimo : size;

  static double? _altura(double? lineHeight, double tamano) {
    if (lineHeight == null) return null;
    final minimo = tamano * 1.15;
    return (lineHeight < minimo ? minimo : lineHeight) / tamano;
  }

  static TextStyle sans(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.onSurface,
    double? lineHeight,
    double letterSpacing = 0,
    FontStyle? style,
    TextDecoration? decoration,
  }) {
    final t = _tamano(size);
    return GoogleFonts.notoSans(
      fontSize: t,
      fontWeight: weight,
      color: color,
      height: _altura(lineHeight, t),
      letterSpacing: letterSpacing,
      fontStyle: style,
      decoration: decoration,
      decorationColor: color,
    );
  }

  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.onSurfaceVariant,
    double? lineHeight,
    double letterSpacing = 0,
  }) {
    final t = _tamano(size);
    return GoogleFonts.jetBrainsMono(
      fontSize: t,
      fontWeight: weight,
      color: color,
      height: _altura(lineHeight, t),
      letterSpacing: letterSpacing,
    );
  }
}

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    fontFamily: GoogleFonts.notoSans().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.background,
    ),
    scaffoldBackgroundColor: AppColors.background,
    datePickerTheme: DatePickerThemeData(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      headerBackgroundColor: Colors.black,
      headerForegroundColor: Colors.white,
      todayBorder: const BorderSide(color: AppColors.accent),
      todayForegroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? Colors.white : AppColors.accent,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.md),
      cancelButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.onSurfaceVariant),
      confirmButtonStyle: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),
  );
}
