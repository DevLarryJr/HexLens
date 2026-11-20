import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class ReservaProgreso extends StatelessWidget {
  const ReservaProgreso({
    super.key,
    required this.paso,
    required this.servicio,
    required this.fotografo,
    required this.cliente,
  });

  final int paso;

  final String servicio;
  final String fotografo;
  final String cliente;

  static const _pasos = ['Cliente', 'Servicio', 'Fecha y hora', 'Confirmar'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconoTexto(const SvgIcon('fecha/sparkle.svg', width: 18.333), 'NUEVA RESERVA',
                estilo: AppText.sans(20, weight: FontWeight.w600, lineHeight: 28, letterSpacing: -0.5), separacion: 4),
            Tag(
              label: 'Paso ${paso + 1} de ${_pasos.length}',
              radius: 0,
              background: AppColors.surfaceHighest,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            for (var i = 0; i < _pasos.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(child: _Paso(_pasos[i], hecho: i < paso, activo: i == paso)),
            ],
          ],
        ),
        const SizedBox(height: 12),
        HexCard(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.sm),
                child: const SvgIcon('fecha/camera.svg', width: 15, height: 13.5),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(servicio,
                        style: AppText.sans(12,
                            weight: FontWeight.w700, color: AppColors.accent, lineHeight: 18, letterSpacing: 0.6)),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(text: '$fotografo ', style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18)),
                        TextSpan(
                            text: '• Cliente: $cliente',
                            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                      ]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 28, height: 28, child: Center(child: SvgIcon('fecha/tune.svg', width: 13.5))),
            ],
          ),
        ),
      ],
    );
  }
}

class _Paso extends StatelessWidget {
  const _Paso(this.label, {required this.hecho, required this.activo});

  final String label;
  final bool hecho;
  final bool activo;

  @override
  Widget build(BuildContext context) {
    final pendiente = !hecho && !activo;
    final barra = activo ? AppColors.accent : (hecho ? Colors.black : AppColors.surfaceHighest);
    final icono = activo ? 'fecha/step_current.svg' : (hecho ? 'fecha/step_done.svg' : 'fecha/step_pending.svg');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(height: 6, color: barra),
            if (activo) const Positioned(right: -4, top: -1, child: Dot(size: 8)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.only(top: 2), child: SvgIcon(icono, width: 10.833)),
            const SizedBox(width: 2),
            Flexible(
              child: Text(label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.sans(10,
                      weight: activo ? FontWeight.w700 : (pendiente ? FontWeight.w400 : FontWeight.w600),
                      color: activo ? AppColors.accent : (pendiente ? AppColors.onSurfaceVariant : Colors.black),
                      lineHeight: 14)),
            ),
          ],
        ),
      ],
    );
  }
}
