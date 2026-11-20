import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.path, {super.key, required this.width, double? height, this.color})
      : height = height ?? width;

  final String path;
  final double width;
  final double height;

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

  final bool arriba;

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

class VolverA {
  const VolverA(this.pantalla);

  final String pantalla;
}

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

  final String? section;

  final String? title;

  final VoidCallback? onBack;

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

  static const double _logoWidth = 112;
  static const double _logoHeight = 34;

  Widget _brand() {
    return Row(
      children: [
        Image.asset('assets/images/logo_hexlens.png',
            width: _logoWidth, height: _logoHeight, fit: BoxFit.contain, alignment: Alignment.centerLeft),
        const SizedBox(width: 12),
        Container(width: 1, height: 24, color: AppColors.surfaceHigh),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            section!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 24, letterSpacing: -0.3),
          ),
        ),
        const UserAvatar(icon: 'agenda/person.svg'),
      ],
    );
  }

  Widget _detail(BuildContext context) {
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
              Text(
                title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppText.sans(titleSize, weight: FontWeight.w600, lineHeight: 20, letterSpacing: -0.2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const UserAvatar(icon: 'detalle/person.svg'),
      ],
    );
  }
}

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

class BlurTopBar extends StatelessWidget {
  const BlurTopBar({
    super.key,
    required this.child,
    this.height = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget child;
  final double height;

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

Future<T?> mostrarHoja<T>(BuildContext context, Widget hoja, {bool oscuro = false}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: oscuro ? AppColors.barrierStrong : AppColors.barrier,
    builder: (_) => hoja,
  );
}

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
