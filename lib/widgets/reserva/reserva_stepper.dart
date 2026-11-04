import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Stepper de 4 pasos con círculos numerados (pasos 2 a 4 del flujo de reserva)
/// y resumen del cliente seleccionado.
class ReservaStepper extends StatelessWidget {
  const ReservaStepper({
    super.key,
    required this.current,
    required this.cliente,
    required this.documento,
  });

  /// Índice 0..3 del paso activo.
  final int current;
  final String cliente;
  final String documento;

  static const _labels = ['Cliente', 'Servicio', 'Fecha y hora', 'Confirmación'];

  @override
  Widget build(BuildContext context) {
    Widget step(int i) {
      final done = i < current;
      final active = i == current;
      return Column(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: done ? AppColors.accent : (active ? Colors.black : AppColors.surfaceHigh),
              borderRadius: AppRadius.lg,
              boxShadow: done || active ? AppShadows.soft : null,
            ),
            child: done
                ? const SvgIcon('servicio/check.svg', width: 12.225, height: 9.019)
                : Text('${i + 1}',
                    style: AppText.sans(14,
                        weight: active ? FontWeight.w700 : FontWeight.w400,
                        color: active ? Colors.white : AppColors.onSurfaceVariant,
                        lineHeight: 18)),
          ),
          const SizedBox(height: 4),
          Text(_labels[i],
              style: AppText.sans(10,
                  weight: done || active ? FontWeight.w600 : FontWeight.w400,
                  color: done || active ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  lineHeight: 18)),
        ],
      );
    }

    Widget line(int i) => Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(4, 0, 4, 22),
            child: Container(height: 2, color: i < current ? AppColors.accent : AppColors.surfaceHigh),
          ),
        );

    return HexCard(
      child: Column(
        children: [
          Row(
            children: [
              step(0),
              line(0),
              step(1),
              line(1),
              step(2),
              line(2),
              step(3),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLow,
              borderRadius: AppRadius.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: AppRadius.md,
                  ),
                  child: const SvgIcon('servicio/client.svg', width: 15),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cliente seleccionado',
                          style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                      Text.rich(
                        TextSpan(children: [
                          // Nombre y documento en líneas separadas: juntos no caben y se cortaban con "…".
                          TextSpan(
                              text: '$cliente\n',
                              style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                          TextSpan(
                              text: documento,
                              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 20)),
                        ]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  child: Text('Cambiar',
                      style: AppText.sans(14,
                          weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
