import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

/// Icono exportado desde Figma (assets/icons/...).
class SvgIcon extends StatelessWidget {
  const SvgIcon(this.path, {super.key, required this.width, double? height, this.color})
      : height = height ?? width;

  final String path;
  final double width;
  final double height;

  /// Tinte opcional (p.ej. estado activo de la barra de navegación).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: SvgPicture.asset(
        'assets/icons/$path',
        width: width,
        height: height,
        fit: BoxFit.fill,
        colorFilter: color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
      ),
    );
  }
}

/// Icono seguido de un texto (filas de metadatos: teléfono, fecha, lugar…). [ajuste] decide si
/// el texto se adapta al ancho (loose) o lo ocupa entero (tight); sin él, mide lo que mida.
class IconoTexto extends StatelessWidget {
  const IconoTexto(this.icono, this.texto,
      {super.key,
      required this.estilo,
      this.separacion = 6,
      this.ajuste,
      this.arriba = false,
      this.compacto = false});

  final Widget icono;
  final String texto;
  final TextStyle estilo;
  final double separacion;
  final FlexFit? ajuste;

  /// Alinea el icono con la primera línea en vez de centrarlo.
  final bool arriba;

  /// Ocupa solo lo que mide su contenido en vez de todo el ancho.
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final text = Text(texto, style: estilo);
    return Row(
      mainAxisSize: compacto ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: arriba ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        icono,
        SizedBox(width: separacion),
        if (ajuste == null) text else Flexible(fit: ajuste!, child: text),
      ],
    );
  }
}

/// Punto de color (indicadores de estado).
class Dot extends StatelessWidget {
  const Dot({super.key, this.size = 6, this.color = AppColors.accent});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Superficie blanca con radio y sombra suave: la tarjeta base del sistema.
class HexCard extends StatelessWidget {
  const HexCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color = AppColors.surface,
    this.radius = 8,
    this.shadow = AppShadows.soft,
    this.accentBar = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final double radius;
  final List<BoxShadow>? shadow;

  /// Barra bermellón de 6px a la izquierda (elemento destacado / seleccionado).
  final bool accentBar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: accentBar
          ? Stack(
              children: [
                Padding(padding: padding, child: child),
                const Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(width: 6, child: ColoredBox(color: AppColors.accent)),
                ),
              ],
            )
          : Padding(padding: padding, child: child),
    );
  }
}

/// Etiqueta pequeña con fondo (badges de estado, chips informativos).
class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.background = AppColors.surfaceContainer,
    this.style,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.radius = 2,
    this.gap = 6,
  });

  final String label;
  final Widget? leading;
  final Widget? trailing;
  final Color background;
  final TextStyle? style;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(radius)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, SizedBox(width: gap)],
          Text(label, style: style ?? AppText.sans(14, lineHeight: 18)),
          if (trailing != null) ...[SizedBox(width: gap), trailing!],
        ],
      ),
    );
  }
}

/// Botón rectangular a ancho completo (variantes primario / secundario / destructivo).
class HexButton extends StatelessWidget {
  const HexButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.background = AppColors.primary,
    this.foreground = Colors.white,
    this.height = 48,
    this.radius = 4,
    this.shadow = AppShadows.soft,
    this.textStyle,
    this.gap = 8,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final Color background;
  final Color foreground;
  final double height;
  final double radius;
  final List<BoxShadow>? shadow;
  final TextStyle? textStyle;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(boxShadow: shadow, borderRadius: BorderRadius.circular(radius)),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onPressed ?? () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leading != null) ...[leading!, SizedBox(width: gap)],
              Text(
                label,
                style: textStyle ??
                    AppText.sans(16, weight: FontWeight.w500, color: foreground, lineHeight: 20),
              ),
              if (trailing != null) ...[SizedBox(width: gap), trailing!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Avatar circular negro con icono de usuario (esquina derecha del header).
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.lg),
      alignment: Alignment.center,
      child: SvgIcon(icon, width: 12),
    );
  }
}

/// Dato que viaja con una ruta (`RouteSettings.arguments`): nombre de la pantalla desde la que se abrió.
/// [HexHeader] lo muestra sobre el título ("AGENDA ›"), así la única flecha de volver dice a dónde regresa.
class VolverA {
  const VolverA(this.pantalla);

  /// Ej.: "Agenda", "Inicio", "Mis Servicios".
  final String pantalla;
}

/// Header translúcido con blur fijo en la parte superior (64px).
class HexHeader extends StatelessWidget {
  const HexHeader({
    super.key,
    this.section,
    this.title,
    this.titleSize = 16,
    this.onBack,
    this.cerrar = false,
  });

  final double titleSize;

  /// Variante "marca": HEXLENS ✦ + nombre de sección (Inicio, Agenda...).
  final String? section;

  /// Variante "detalle": botón volver + logo + título.
  final String? title;

  /// Por defecto vuelve a la pantalla anterior.
  final VoidCallback? onBack;

  /// ✕ en vez de ←: la pantalla es una tarea (formulario, nueva reserva) que se cierra, no un lugar al que se
  /// navega. Es su única salida sin guardar.
  final bool cerrar;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.glassHeader,
            boxShadow: AppShadows.header,
          ),
          child: SafeArea(
            bottom: false,
            child: SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: title != null ? _detail(context) : _brand(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _brand() {
    return Row(
      children: [
        Image.asset('assets/images/logo_hexlens.png', width: 128, height: 38, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('HEXLENS',
                      style: AppText.sans(16,
                          weight: FontWeight.w600,
                          color: Colors.black,
                          lineHeight: 24,
                          letterSpacing: -0.4)),
                  const SizedBox(width: 6),
                  const SvgIcon('agenda/sparkle.svg', width: 12.833),
                ],
              ),
              Text(section!.toUpperCase(),
                  style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            ],
          ),
        ),
        const UserAvatar(icon: 'agenda/person.svg'),
      ],
    );
  }

  Widget _detail(BuildContext context) {
    // Pantalla de origen (si la ruta la trae): se muestra como miga sobre el título.
    final args = ModalRoute.settingsOf(context)?.arguments;
    final origen = onBack == null && !cerrar && args is VolverA ? args.pantalla : null;
    return Row(
      children: [
        Semantics(
          button: true,
          label: cerrar ? 'Cerrar' : (origen == null ? 'Volver' : 'Volver a $origen'),
          excludeSemantics: true,
          child: SizedBox(
            width: 32,
            height: 44,
            child: InkWell(
              borderRadius: AppRadius.lg,
              onTap: onBack ?? () => Navigator.of(context).maybePop(),
              child: Center(
                child: cerrar
                    ? const Icon(Icons.close, size: 20, color: AppColors.onSurface)
                    : const SvgIcon('detalle/arrow_back.svg', width: 14.667),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        Image.asset('assets/images/logo_hexlens.png', width: 128, height: 44, fit: BoxFit.contain),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (origen != null)
                Text('${origen.toUpperCase()} ›',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 16, letterSpacing: 0.6)),
              // Hasta 2 líneas: el espacio junto al logo es estrecho y los títulos no deben cortarse.
              Text(
                title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.sans(titleSize, weight: FontWeight.w600, lineHeight: 20, letterSpacing: -0.2),
              ),
            ],
          ),
        ),
        const SvgIcon('detalle/sparkle.svg', width: 14.667),
        const SizedBox(width: 4),
        const UserAvatar(icon: 'detalle/person.svg'),
      ],
    );
  }
}

/// Barra de navegación inferior (Inicio · Agenda · Clientes · Más).
class HexBottomNav extends StatelessWidget {
  const HexBottomNav({super.key, required this.currentIndex, required this.onTap});

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    ('Inicio', 'nav/inicio.svg', 18.0, 18.0),
    ('Agenda', 'nav/agenda_inactive.svg', 18.0, 20.0),
    ('Clientes', 'nav/clientes.svg', 22.0, 16.0),
    ('Más', 'nav/mas.svg', 18.0, 18.0),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.glassBar,
            boxShadow: [BoxShadow(color: Color(0x0F141414), offset: Offset(0, -2), blurRadius: 12)],
          ),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 80,
              child: Row(
                children: [
                  for (var i = 0; i < _items.length; i++)
                    Expanded(
                      child: InkWell(
                        onTap: () => onTap(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgIcon(
                              _items[i].$2,
                              width: _items[i].$3,
                              height: _items[i].$4,
                              color: i == currentIndex ? AppColors.accent : AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _items[i].$1,
                              style: AppText.sans(14,
                                  color: i == currentIndex
                                      ? AppColors.accent
                                      : AppColors.onSurfaceVariant,
                                  lineHeight: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Layout común: contenido desplazable bajo un header fijo translúcido.
class HeaderScaffold extends StatelessWidget {
  const HeaderScaffold({
    super.key,
    required this.header,
    required this.children,
    this.bottomPadding = 112,
    this.overlay,
    this.bottomBar,
  });

  final Widget header;
  final List<Widget> children;
  final double bottomPadding;
  final Widget? overlay;
  final Widget? bottomBar;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      bottomNavigationBar: bottomBar,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 64 + topInset, 20, bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: header),
          ?overlay,
        ],
      ),
    );
  }
}

/// Barra inferior fija con fondo crema translúcido desenfocado y sombra hacia
/// arriba (pies de reserva y reagendar). Respeta el área segura inferior.
class BlurBottomBar extends StatelessWidget {
  const BlurBottomBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.color = AppColors.glassBar,
    this.blur = 6,
    this.shadow = AppShadows.bottomBar,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color color;
  final double blur;
  final List<BoxShadow> shadow;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(color: color, boxShadow: shadow),
          padding: padding,
          child: SafeArea(top: false, child: child),
        ),
      ),
    );
  }
}

/// Barra superior fija con fondo translúcido desenfocado, de [height] px más
/// el área segura superior. Para pantallas con header propio (no [HexHeader]).
class BlurTopBar extends StatelessWidget {
  const BlurTopBar({
    super.key,
    required this.child,
    this.height = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget child;
  final double height;

  /// Solo se usan los lados izquierdo y derecho.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: AppColors.glassHeader,
          padding: EdgeInsets.fromLTRB(padding.left, top, padding.right, 0),
          height: height + top,
          child: child,
        ),
      ),
    );
  }
}

/// Triángulo de color en una esquina superior derecha (marca de tarjeta).
class EsquinaTriangulo extends StatelessWidget {
  const EsquinaTriangulo({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size(size, size), painter: _TrianguloPainter(color));
}

class _TrianguloPainter extends CustomPainter {
  const _TrianguloPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TrianguloPainter old) => old.color != color;
}

/// Asa gris centrada en la parte superior de las hojas modales.
class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key, this.width = 64});

  final double width;

  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: width,
          height: 5,
          decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.sm),
        ),
      );
}

/// Abre [hoja] como hoja inferior transparente de alto libre sobre un velo gris
/// ([oscuro] lo hace más opaco). Devuelve lo que la hoja pase a `Navigator.pop`.
Future<T?> mostrarHoja<T>(BuildContext context, Widget hoja, {bool oscuro = false}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: oscuro ? AppColors.barrierStrong : AppColors.barrier,
    builder: (_) => hoja,
  );
}

/// Redibuja la pantalla cada vez que cambia [escuchar] (p. ej. el directorio de clientes).
mixin RedibujarAlCambiar<T extends StatefulWidget> on State<T> {
  Listenable get escuchar;

  void _redibujar() => setState(() {});

  @override
  void initState() {
    super.initState();
    escuchar.addListener(_redibujar);
  }

  @override
  void dispose() {
    escuchar.removeListener(_redibujar);
    super.dispose();
  }
}
