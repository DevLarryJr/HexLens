import 'package:flutter/material.dart';

import '../../models/sesion.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../hex_widgets.dart';

class SesionCard extends StatelessWidget {
  const SesionCard({super.key, required this.sesion, this.onTap});

  final Sesion sesion;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = sesion;
    if (s.cancelada) return SesionCanceladaCard(sesion: s);

    final staffLine = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        s.destacada
            ? const SvgIcon('agenda/camera_small.svg', width: 13.333, height: 12)
            : const SvgIcon('agenda/photographer.svg', width: 13.333),
        const SizedBox(width: 6),
        Text(s.fotografo, style: AppText.sans(14, lineHeight: 18)),
        const SizedBox(width: 6),
        Text('•', style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 24)),
        const SizedBox(width: 6),
        Text(s.pago, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
      ],
    );

    final precio = formatCop(s.precio ?? 0);

    final footer = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.xs),
      child: s.destacada
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [staffLine, const SizedBox(height: 8), _PrecioText(precio, size: 20)],
            )
          : Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 8,
              spacing: 8,
              children: [staffLine, _PrecioText(precio)],
            ),
    );

    final inset = s.destacada ? const EdgeInsets.only(left: 4) : EdgeInsets.zero;

    return GestureDetector(
      onTap: onTap,
      child: HexCard(
        accentBar: s.destacada,
        shadow: s.destacada ? AppShadows.medium : AppShadows.soft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: inset,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _Horario(s),
                          if (s.destacada) ...[
                            const SizedBox(width: 8),
                            const SvgIcon('agenda/live.svg', width: 13.333),
                          ],
                        ],
                      ),
                      Text('${s.lugar} • ${s.duracionMin} min',
                          style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                    ],
                  ),
                  EstadoBadge(sesion: s),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: inset,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s.cliente, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                      if (s.destacada)
                        Row(
                          children: [
                            Text('Toque para gestionar',
                                style: AppText.sans(14,
                                    weight: FontWeight.w500, color: AppColors.accent, lineHeight: 18)),
                            const SizedBox(width: 2),
                            const SvgIcon('agenda/chevron_down.svg', width: 8, height: 4.933),
                          ],
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(s.descripcion, style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 24)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(padding: inset, child: footer),
          ],
        ),
      ),
    );
  }
}

class SesionCanceladaCard extends StatelessWidget {
  const SesionCanceladaCard({super.key, required this.sesion});

  final Sesion sesion;

  @override
  Widget build(BuildContext context) {
    final s = sesion;
    return Opacity(
      opacity: 0.8,
      child: HexCard(
        color: AppColors.surfaceLow,
        shadow: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Horario(s, tachado: true),
                    Text('${s.lugar} • ${s.duracionMin} min',
                        style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                  ],
                ),
                EstadoBadge(sesion: s),
              ],
            ),
            const SizedBox(height: 12),
            Text(s.cliente,
                style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24, decoration: TextDecoration.lineThrough)),
            const SizedBox(height: 4),
            Row(
              children: [
                const SvgIcon('agenda/error.svg', width: 13.333),
                const SizedBox(width: 4),
                Text(s.motivo ?? '',
                    style: AppText.sans(16, weight: FontWeight.w500, color: AppColors.accent, lineHeight: 24)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconoTexto(const SvgIcon('agenda/person_off.svg', width: 13.217), s.fotografo,
                      estilo: AppText.sans(14,
                              color: AppColors.onSurfaceVariant,
                              lineHeight: 18,
                              decoration: TextDecoration.lineThrough)),
                  Text('Liberado para asignación',
                      style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, style: FontStyle.italic)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EstadoBadge extends StatelessWidget {
  const EstadoBadge({super.key, required this.sesion});

  final Sesion sesion;

  @override
  Widget build(BuildContext context) {
    switch (sesion.estado) {
      case SesionEstado.realizada:
        return Tag(
          label: 'Realizada',
          gap: 4,
          leading: const SvgIcon('agenda/done.svg', width: 13.333),
          style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18),
        );
      case SesionEstado.cancelada:
        return Tag(
          label: 'Cancelada',
          gap: 4,
          background: AppColors.surfaceHigh,
          leading: const SvgIcon('agenda/close.svg', width: 9.333),
          style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 18),
        );
      case SesionEstado.programada:
        final destacada = sesion.destacada;
        return Tag(
          label: 'Programada',
          leading: const Dot(size: 8),
          background: destacada ? AppColors.accentContainer : AppColors.surfaceContainer,
          style: AppText.sans(14,
              weight: destacada ? FontWeight.w500 : FontWeight.w400,
              color: destacada ? AppColors.onAccentContainer : AppColors.onSurface,
              lineHeight: 18),
        );
    }
  }
}

class _Horario extends StatelessWidget {
  const _Horario(this.sesion, {this.tachado = false});

  final Sesion sesion;
  final bool tachado;

  @override
  Widget build(BuildContext context) {
    final inicio = horaCorta(sesion.inicio);
    final fin = horaCorta(sesion.fin);
    if (tachado) {
      return Text('$inicio - $fin',
          style: AppText.sans(20,
              weight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
              lineHeight: 28,
              letterSpacing: -0.5,
              decoration: TextDecoration.lineThrough));
    }
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: '$inicio ', style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 28, letterSpacing: -0.5)),
        TextSpan(
            text: '- $fin',
            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: -0.5)),
      ]),
    );
  }
}

class _PrecioText extends StatelessWidget {
  const _PrecioText(this.precio, {this.size = 16});

  final String precio;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        TextSpan(
            text: '$precio ',
            style: AppText.sans(size,
                weight: FontWeight.w700, lineHeight: size == 16 ? 24 : 28, letterSpacing: size == 16 ? 0 : -0.2)),
        TextSpan(text: 'COP', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
      ]),
    );
  }
}
