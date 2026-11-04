import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tokens de color del design system HexLens (Figma: "Paleta de Colores y font").
class AppColors {
  static const background = Color(0xFFFCF9F2);

  /// `background` translúcido para superficies con blur: 85 % (headers),
  /// 90 % (barras inferiores) y 95 % (pies y paneles).
  static const glassHeader = Color(0xD9FCF9F2);
  static const glassBar = Color(0xE6FCF9F2);
  static const glassSolid = Color(0xF2FCF9F2);
  static const surface = Colors.white;

  /// Blanco al 80 %: tarjetas atenuadas (sesiones ya realizadas).
  static const surfaceFaded = Color(0xCCFFFFFF);
  static const surfaceLow = Color(0xFFF6F3EC);
  static const surfaceContainer = Color(0xFFF1EEE7);
  static const surfaceHigh = Color(0xFFEBE8E1);
  static const surfaceHighest = Color(0xFFE5E2DB);

  /// `surfaceHigh` al 60 %: bloques ocupados.
  static const surfaceHighFaded = Color(0x99EBE8E1);

  /// `surfaceHigh` al 40 %: halo exterior del logo del splash.
  static const surfaceHighGhost = Color(0x66EBE8E1);

  /// `surfaceHighest` al 60 %: mira central del visor del splash.
  static const surfaceHighestFaded = Color(0x99E5E2DB);

  /// `surfaceHighest` al 20 %: etiquetas sobre fondo negro.
  static const onDarkFaint = Color(0x33E5E2DB);

  /// `surfaceHighest` al 30 %: contadores sobre chips negros.
  static const onDarkSoft = Color(0x4DE5E2DB);

  static const onSurface = Color(0xFF1C1C18);
  static const onSurfaceVariant = Color(0xFF444748);
  static const outline = Color(0xFF616565); // contraste 5,6:1 sobre el fondo (antes #747878, 4,2:1)
  static const outlineVariant = Color(0xFFC4C7C7);

  /// `outlineVariant` al 30 %: líneas divisorias suaves.
  static const outlineFaint = Color(0x4DC4C7C7);

  /// Negro al 80 %: velos sobre fotos.
  static const scrim = Color(0xCC000000);
  static const scrimSoft = Color(0xB3000000);

  /// Velo detrás de las hojas modales (60 % y 70 %).
  static const barrier = Color(0x99363636);
  static const barrierStrong = Color(0xB3363636);

  /// Borde rosado de las hojas de acciones destructivas.
  static const accentBorder = Color(0xFFF1B5AA);

  /// `onSurfaceVariant` al 40 %: textos y fechas deshabilitados.
  static const disabled = Color(0x66444748);

  /// Punto neutro de "disponible".
  static const neutralDot = Color(0xFF5F5E5E);
  static const muted = Color(0xFF62686F); // contraste ≥ 4,5:1 (antes #7E848C, 3,7:1)

  static const primary = Colors.black;
  static const ink = Color(0xFF1C1B1B);

  /// Bermellón: acento de marca.
  static const accent = Color(0xFFB61800);
  static const accentBright = Color(0xFFDB351A);

  /// `accentBright` al 13 %: halo del control deslizante.
  static const accentOverlay = Color(0x22DB351A);

  /// Texto sobre `accentBright` (blanco cálido).
  static const onAccentBright = Color(0xFFFFFBFF);
  static const accentContainer = Color(0xFFFFDAD3);

  /// `accentContainer` al 50 %.
  static const accentTint = Color(0x80FFDAD3);

  /// `accent` al 15 %.
  static const accentFaint = Color(0x26B61800);

  /// `accent` al 10 %: esquinas y fondos de íconos destacados.
  static const accentWash = Color(0x1AB61800);
  static const onAccentContainer = Color(0xFF3F0300);

  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);

  /// Rojo claro de la etiqueta de código de error ("ERR_422").
  static const errorTag = Color(0xFFFFB4AB);

  /// Fondo muy suave de los mensajes de error bajo un campo.
  static const errorWash = Color(0xFFFFE9E5);

  static const darkMuted = Color(0xFF858383);

  /// Contenedor neutro azulado (etiqueta de jornada especial).
  static const neutralContainer = Color(0xFFDDE3EB);
  static const onNeutralContainer = Color(0xFF161C22);

  /// Gris oscuro de los contadores sobre un chip seleccionado (negro).
  static const graphite = Color(0xFF3A3A3A);

  /// Gris carbón para etiquetas sobre paneles negros.
  static const charcoal = Color(0xFF333333);

  /// Relleno de elementos desactivados (foto de staff inactivo, cintas).
  static const surfaceDim = Color(0xFFDCDAD3);

  /// Verde de validación correcta.
  static const success = Color(0xFF16A34A);

  /// Verde de WhatsApp (canal directo del cliente).
  static const whatsapp = Color(0xFF22A55B);
  static const successDark = Color(0xFF166534);

  /// Verde muy claro de los estados válidos ("OK_STATE").
  static const successContainer = Color(0xFFE6F4E7);
}

/// Radios de esquina de la app (las cuatro únicas medidas que usa el diseño).
class AppRadius {
  /// Etiquetas, cajas de nota y botones rectos.
  static const xs = BorderRadius.all(Radius.circular(2));

  /// Tarjetas y campos.
  static const sm = BorderRadius.all(Radius.circular(4));

  /// Paneles y tarjetas grandes.
  static const md = BorderRadius.all(Radius.circular(8));

  /// Pastillas, contadores y avatares cuadrados.
  static const lg = BorderRadius.all(Radius.circular(12));
}

/// Filtros de color reutilizables.
class AppFilters {
  /// Escala de grises (luminancia Rec. 709).
  static const grayscale = ColorFilter.matrix(<double>[
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0, //
    0, 0, 0, 1, 0,
  ]);
}

class AppShadows {
  /// drop-shadow 0 1 1 rgba(0,0,0,.05)
  static const soft = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 1),
  ];

  /// shadow-sm: 0 1 2 rgba(0,0,0,.05). Tarjetas y campos de búsqueda.
  static const hairline = [
    BoxShadow(color: Color(0x0D000000), offset: Offset(0, 1), blurRadius: 2),
  ];

  /// shadow-md
  static const medium = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
  ];

  /// shadow-xl
  static const large = [
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 20), blurRadius: 25, spreadRadius: -5),
    BoxShadow(color: Color(0x1A000000), offset: Offset(0, 8), blurRadius: 10, spreadRadius: -6),
  ];

  /// Sombra hacia arriba de la barra de acciones de las hojas modales.
  static const sheetActions = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, -2), blurRadius: 8),
  ];

  /// Sombra hacia arriba de las barras inferiores fijas.
  static const bottomBar = [
    BoxShadow(color: Color(0x0F000000), offset: Offset(0, -4), blurRadius: 16),
  ];

  static const header = [
    BoxShadow(color: Color(0x0A000000), offset: Offset(0, 1), blurRadius: 8),
  ];
}

/// Tipografía: Noto Sans para UI, JetBrains Mono para telemetría.
///
/// Ningún texto baja de [tamanoMinimo] (legibilidad en el teléfono) y el interlineado
/// nunca queda por debajo de 1,15 veces el tamaño.
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
    // Calendarios con los colores de la app (sin el tinte rosado de Material 3).
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
