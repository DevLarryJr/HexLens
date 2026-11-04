import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// "RESUMEN DE OPERACIÓN": sesiones del día, pendientes y realizadas.
class KpiResumen extends StatelessWidget {
  const KpiResumen({super.key, required this.total, required this.pendientes, required this.realizadas});

  final int total;
  final int pendientes;
  final int realizadas;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RESUMEN DE OPERACIÓN',
                style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.outline, lineHeight: 18, letterSpacing: 0.7)),
            Text('Estudio Principal',
                style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.accent, lineHeight: 18)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _KpiCard(
              icon: const SvgIcon('inicio/kpi_total.svg', width: 15, height: 13.5),
              tag: Text('TOTAL',
                  style: AppText.sans(10, weight: FontWeight.w700, color: AppColors.outline, lineHeight: 15)),
              value: '$total',
              label: 'Sesiones día',
            ),
            const SizedBox(width: 8),
            _KpiCard(
              icon: const SvgIcon('inicio/kpi_pending.svg', width: 15),
              tag: Tag(
                label: 'En cola',
                background: AppColors.accentContainer,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                style: AppText.sans(11, weight: FontWeight.w600, color: AppColors.onAccentContainer, lineHeight: 16.5),
              ),
              value: '$pendientes',
              label: 'Pendientes',
            ),
            const SizedBox(width: 8),
            _KpiCard(
              icon: const SvgIcon('inicio/kpi_done.svg', width: 15),
              tag: Tag(
                label: 'Listas',
                background: AppColors.surfaceHigh,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                style: AppText.sans(11, weight: FontWeight.w500, lineHeight: 16.5),
              ),
              value: '$realizadas',
              label: realizadas == 1 ? 'Realizada' : 'Realizadas',
            ),
          ],
        ),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.icon, required this.tag, required this.value, required this.label});

  final Widget icon;
  final Widget tag;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: HexCard(
        radius: 4,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 16.5,
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [icon, tag]),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: AppText.sans(28, weight: FontWeight.w700, color: Colors.black, lineHeight: 32, letterSpacing: -0.84)),
            const SizedBox(height: 3),
            Text(label, style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 15)),
          ],
        ),
      ),
    );
  }
}
