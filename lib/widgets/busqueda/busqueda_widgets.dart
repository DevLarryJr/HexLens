import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_chips.dart';
import '../hex_widgets.dart';

class BusquedaHeader extends StatelessWidget {
  const BusquedaHeader({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) => HexHeader(title: 'Búsqueda', onBack: onBack);
}

class BusquedaNav extends StatelessWidget {
  const BusquedaNav({super.key, this.onTap});

  final ValueChanged<int>? onTap;

  static const _items = [
    ('busqueda/nav_sesiones.svg', 16.5, 16.5, 'Sesiones'),
    ('busqueda/nav_catalogo.svg', 18.3, 11.9, 'Catálogo'),
    ('busqueda/nav_equipos.svg', 18.3, 16.5, 'Equipos'),
    ('busqueda/nav_ajustes.svg', 16.5, 16.5, 'Ajustes'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.glassSolid,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            children: [
              for (final (i, (icono, w, h, label)) in _items.indexed)
                Expanded(
                  child: InkWell(
                    onTap: onTap == null ? null : () => onTap!(i),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgIcon(icono, width: w, height: h),
                        const SizedBox(height: 4),
                        Text(label, style: AppText.sans(17, color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class BusquedaFiltroChip extends StatelessWidget {
  const BusquedaFiltroChip({super.key, required this.label, required this.count, required this.selected, this.onTap});

  final String label;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return HexChip(
      label: label,
      selected: selected,
      onTap: onTap,
      color: AppColors.surfaceHigh,
      foreground: AppColors.onSurfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 42,
      style: AppText.sans(18, weight: selected ? FontWeight.w500 : FontWeight.w400),
      trailingGap: 8,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
        decoration: BoxDecoration(
          color: selected ? AppColors.graphite : AppColors.surfaceContainer,
          borderRadius: AppRadius.lg,
        ),
        child: Text('$count', style: AppText.sans(13, color: selected ? Colors.white : AppColors.onSurfaceVariant)),
      ),
    );
  }
}

class QueryEstadoBar extends StatelessWidget {
  const QueryEstadoBar({super.key, required this.coincidencias});

  final int coincidencias;

  @override
  Widget build(BuildContext context) {
    final vacio = coincidencias == 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.surfaceContainer,
      child: Row(
        children: [
          Dot(size: 7, color: vacio ? AppColors.accent : AppColors.success),
          const SizedBox(width: 10),
          Expanded(
            child: Text(vacio ? 'SIN RESULTADOS' : 'RESULTADOS',
                style: AppText.sans(14, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
          ),
          Text(vacio ? '0 coincidencias' : '$coincidencias ${coincidencias == 1 ? 'coincidencia' : 'coincidencias'}',
              style: AppText.mono(13, color: vacio ? AppColors.accent : AppColors.successDark)),
        ],
      ),
    );
  }
}

class ResultadoBusquedaCard extends StatelessWidget {
  const ResultadoBusquedaCard({
    super.key,
    required this.icon,
    required this.titulo,
    required this.detalle,
    required this.tipo,
  });

  final IconData icon;
  final String titulo;
  final String detalle;

  final String tipo;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            color: AppColors.surfaceContainer,
            child: Icon(icon, color: AppColors.onSurface),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppText.sans(17, weight: FontWeight.w600)),
                Text(detalle, style: AppText.sans(14, color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          Text(tipo, style: AppText.mono(11, color: AppColors.accent, letterSpacing: 1)),
        ],
      ),
    );
  }
}

class SinResultados extends StatelessWidget {
  const SinResultados({super.key, required this.consulta, this.onRestablecer, this.onRegistrar});

  final String consulta;
  final VoidCallback? onRestablecer;
  final VoidCallback? onRegistrar;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 260,
            height: 290,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: 256,
                  height: 256,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppRadius.md,
                    boxShadow: AppShadows.soft,
                  ),
                  child: const CustomPaint(painter: _SinResultadosPainter()),
                ),
                Positioned(
                  top: 246,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    color: Colors.black,
                    child: Row(
                      children: [
                        const Dot(size: 7, color: AppColors.accentBright),
                        const SizedBox(width: 8),
                        Text('SIN COINCIDENCIAS',
                            style: AppText.sans(14, weight: FontWeight.w600, color: Colors.white, letterSpacing: 1)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('No se encontraron registros', textAlign: TextAlign.center, style: AppText.sans(26, weight: FontWeight.w600)),
        const SizedBox(height: 6),
        Text(
            consulta.isEmpty
                ? 'Escribe un nombre, servicio o número de documento.'
                : 'No existen perfiles, agendas ni equipos vinculados a "$consulta".',
            textAlign: TextAlign.center,
            style: AppText.sans(20, color: AppColors.onSurfaceVariant, lineHeight: 30)),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(20),
          color: AppColors.surfaceLow,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                color: AppColors.surfaceHigh,
                child: const Icon(Icons.info_outline, size: 18),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SUGERENCIA',
                        style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 1)),
                    const SizedBox(height: 4),
                    Text(
                        'Comprueba la ortografía, retira acentos o consulta directamente por número de identificación tributaria (NIT / C.C.).',
                        style: AppText.sans(18, lineHeight: 30)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 60),
        HexButton(
          label: 'Limpiar búsqueda',
          radius: 2,
          height: 62,
          shadow: AppShadows.soft,
          background: AppColors.surfaceHigh,
          foreground: AppColors.onSurface,
          onPressed: onRestablecer,
          leading: const SvgIcon('busqueda/reset.svg', width: 12, height: 13.8),
          textStyle: AppText.sans(20, weight: FontWeight.w500),
        ),
        const SizedBox(height: 16),
        if (consulta.isNotEmpty)
          HexButton(
            label: 'Registrar "$consulta"',
            radius: 2,
            height: 62,
            onPressed: onRegistrar,
            leading: const SvgIcon('busqueda/registrar.svg', width: 16.5, height: 12),
            trailing: const SvgIcon('busqueda/arrow.svg', width: 10.7, height: 10.7),
            textStyle: AppText.sans(20, weight: FontWeight.w500, color: Colors.white),
          ),
      ],
    );
  }
}

class _SinResultadosPainter extends CustomPainter {
  const _SinResultadosPainter();

  static const _trazo = Color(0xFFA0A0A0);
  static const _cruz = Color(0xFF888888);

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final gris = Paint()
      ..color = _trazo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (final o in [
      const Offset(14, 14),
      Offset(size.width - 14, 14),
      Offset(14, size.height - 14),
      Offset(size.width - 14, size.height - 14),
    ]) {
      tp.text = const TextSpan(text: '+', style: TextStyle(color: _cruz, fontSize: 12));
      tp.layout();
      tp.paint(canvas, o - Offset(tp.width / 2, tp.height / 2));
    }
    final marca = Paint()
      ..color = AppColors.outlineVariant
      ..strokeWidth = 2;
    canvas.drawLine(Offset(c.dx - 10, 6), Offset(c.dx + 10, 6), marca);
    canvas.drawLine(Offset(6, c.dy - 10), Offset(6, c.dy + 10), marca);
    canvas.drawLine(Offset(size.width - 6, c.dy - 10), Offset(size.width - 6, c.dy + 10), marca);

    const r = 46.0;
    final pts = [for (var i = 0; i < 6; i++) c + Offset.fromDirection(math.pi / 6 + i * math.pi / 3, r)];
    final punteado = Paint()
      ..color = _trazo
      ..strokeWidth = 1.5;
    for (var i = 0; i < 6; i++) {
      final a = pts[i], b = pts[(i + 1) % 6];
      const segs = 7;
      for (var s = 0; s < segs; s++) {
        final t0 = s / segs, t1 = (s + 0.55) / segs;
        canvas.drawLine(Offset.lerp(a, b, t0)!, Offset.lerp(a, b, t1)!, punteado);
      }
    }

    canvas.drawCircle(c, 30, gris);
    canvas.drawCircle(c, 18, gris);
    canvas.drawCircle(c, 4, Paint()..color = _trazo);

    final rojo = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(c + const Offset(-36, 36), c + const Offset(36, -36), rojo);
    final star = Path();
    final sc = c + const Offset(26, -20);
    for (var i = 0; i < 8; i++) {
      final rr = i.isEven ? 7.0 : 2.0;
      final p = sc + Offset.fromDirection(-math.pi / 2 + i * math.pi / 4, rr);
      i == 0 ? star.moveTo(p.dx, p.dy) : star.lineTo(p.dx, p.dy);
    }
    star.close();
    canvas.drawPath(star, Paint()..color = AppColors.accent);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
