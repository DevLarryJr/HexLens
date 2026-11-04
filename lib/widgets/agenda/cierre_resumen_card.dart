import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Tarjeta negra "Cierre Operativo Proyectado" con el total confirmado y las
/// horas en set del día.
class CierreResumenCard extends StatelessWidget {
  const CierreResumenCard({super.key, required this.fecha, required this.total, required this.horas});

  /// Ej.: "15 OCT".
  final String fecha;

  /// Ej.: "$700.000".
  final String total;

  /// Ej.: "4.25 h".
  final String horas;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      color: Colors.black,
      shadow: AppShadows.medium,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: IconoTexto(const SvgIcon('agenda/payments.svg', width: 20.167, height: 14.667),
                    'Cierre Operativo Proyectado',
                    estilo: AppText.sans(16, weight: FontWeight.w600, color: Colors.white, lineHeight: 24),
                    separacion: 8,
                    ajuste: FlexFit.loose),
              ),
              const SizedBox(width: 8),
              Tag(
                label: fecha,
                background: AppColors.surfaceHighest,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                style: AppText.sans(14, weight: FontWeight.w500, color: Colors.black, lineHeight: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Metrica('Total Confirmado', total),
              const SizedBox(width: 8),
              _Metrica('Horas en Set', horas),
            ],
          ),
        ],
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica(this.label, this.valor);

  final String label;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.sans(14, color: AppColors.darkMuted, lineHeight: 18)),
          Text(valor,
              style: AppText.sans(28, weight: FontWeight.w700, color: Colors.white, lineHeight: 32, letterSpacing: -0.84)),
        ],
      ),
    );
  }
}
