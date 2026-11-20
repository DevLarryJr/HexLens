import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class PoliticaCard extends StatelessWidget {
  const PoliticaCard({super.key, required this.horasAntelacion, required this.telefono});

  final int horasAntelacion;
  final String telefono;

  @override
  Widget build(BuildContext context) {
    final regular = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 19.25);
    final bold = AppText.sans(14, weight: FontWeight.w700, color: AppColors.onSurfaceVariant, lineHeight: 19.25);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.sm,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.xs),
            child: const SvgIcon('reagendar/policy.svg', width: 12, height: 15),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Política de Reagendamiento Operativo',
                    style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 24)),
                const SizedBox(height: 4),
                Text.rich(TextSpan(style: regular, children: [
                  const TextSpan(text: 'Cambio libre de penalidad con hasta '),
                  TextSpan(text: '$horasAntelacion horas de antelación', style: bold),
                  const TextSpan(
                      text: '. Se disparará una confirmación automática por WhatsApp y SMS al '
                          'cliente al número '),
                  TextSpan(text: telefono, style: bold),
                  const TextSpan(text: '.'),
                ])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
