import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Resumen "SESIÓN CONFIGURADA" del paso de fecha: fecha y hora elegidas,
/// tarifa final y botones para seguir o volver.
class SesionConfiguradaCard extends StatelessWidget {
  const SesionConfiguradaCard({
    super.key,
    required this.fecha,
    required this.tarifa,
    required this.onBack,
    this.onContinuar,
  });

  /// Ej.: "Jueves, 15 Oct • 11:00 AM".
  final String fecha;

  /// Ej.: "$120.000 COP".
  final String tarifa;
  final VoidCallback onBack;
  final VoidCallback? onContinuar;

  @override
  Widget build(BuildContext context) {
    final etiqueta = AppText.sans(11, color: AppColors.onSurfaceVariant, lineHeight: 16.5, letterSpacing: 0.55);
    return HexCard(
      shadow: AppShadows.large,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SESIÓN CONFIGURADA', style: etiqueta),
                    IconoTexto(const SvgIcon('fecha/calendar.svg', width: 12, height: 13.333), fecha,
                        estilo: AppText.sans(15, weight: FontWeight.w700, lineHeight: 22.5), ajuste: FlexFit.loose),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 5),
                  Text('TARIFA FINAL', style: etiqueta),
                  Text(tarifa, style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 24)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          HexButton(
            label: 'Continuar a Confirmación',
            radius: 0,
            shadow: AppShadows.medium,
            onPressed: onContinuar,
            trailing: const SvgIcon('fecha/arrow_forward.svg', width: 12),
          ),
          const SizedBox(height: 8),
          HexButton(
            label: 'Volver a Servicio',
            radius: 0,
            height: 44,
            shadow: null,
            onPressed: onBack,
            background: AppColors.surfaceContainer,
            textStyle: AppText.sans(15, lineHeight: 22.5),
            leading: const SvgIcon('fecha/arrow_back.svg', width: 12),
          ),
        ],
      ),
    );
  }
}
