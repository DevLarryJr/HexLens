import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Pie fijo del paso 2 de la reserva: resumen (precio • duración y asignación)
/// sobre fondo desenfocado, y botones Volver / Continuar.
class ResumenFooter extends StatelessWidget {
  const ResumenFooter({
    super.key,
    required this.precio,
    required this.duracion,
    required this.asignacion,
    required this.onBack,
    this.onContinuar,
  });

  /// Precio ya formateado, sin "COP".
  final String precio;
  final String duracion;

  /// Ej.: "Fotógrafa disponible" o "Auto-asignación".
  final String asignacion;
  final VoidCallback onBack;
  final VoidCallback? onContinuar;

  @override
  Widget build(BuildContext context) {
    return BlurBottomBar(
      color: AppColors.glassSolid,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: AppRadius.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Flexible + scaleDown: con precios de 6 cifras y 120+ min el
                // resumen no cabe junto a la asignación y se reduce un poco.
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RESUMEN',
                        style: AppText.sans(
                          14,
                          color: AppColors.onSurfaceVariant,
                          lineHeight: 18,
                          letterSpacing: 0.7,
                        ),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: '$precio COP ',
                                style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24),
                              ),
                              TextSpan(
                                text: '• $duracion',
                                style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconoTexto(const SvgIcon('servicio/available.svg', width: 14.667, height: 14), asignacion,
                    estilo: AppText.sans(
                        14,
                        weight: FontWeight.w600,
                        color: AppColors.accent,
                        lineHeight: 18,
                      ), separacion: 4),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              SizedBox(
                width: 110,
                child: HexButton(
                  label: 'Volver',
                  onPressed: onBack,
                  gap: 4,
                  shadow: null,
                  background: AppColors.surfaceContainer,
                  textStyle: AppText.sans(16, weight: FontWeight.w600, lineHeight: 20),
                  leading: const SvgIcon('servicio/arrow_back.svg', width: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HexButton(
                  label: 'Continuar',
                  onPressed: onContinuar,
                  textStyle: AppText.sans(16, weight: FontWeight.w600, color: Colors.white, lineHeight: 20),
                  trailing: const SvgIcon('servicio/arrow_forward.svg', width: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
