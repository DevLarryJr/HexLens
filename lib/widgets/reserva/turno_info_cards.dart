import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class JornadaInfoCard extends StatelessWidget {
  const JornadaInfoCard({super.key, required this.texto});

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.lg),
            child: const SvgIcon('fecha/info.svg', width: 12.5),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Parámetros Operativos del Turno', style: AppText.sans(13, lineHeight: 16.25)),
                const SizedBox(height: 2),
                Text(texto, style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 19.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SetAsignadoCard extends StatelessWidget {
  const SetAsignadoCard({super.key, required this.set, required this.equipo});

  final String set;
  final String equipo;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.sm),
            child: const SvgIcon('fecha/set.svg', width: 18.333),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('ASIGNACIÓN AUTOMÁTICA',
                        style: AppText.sans(11,
                            weight: FontWeight.w700, color: AppColors.accent, lineHeight: 16.5, letterSpacing: 0.55)),
                    const SizedBox(width: 6),
                    const Dot(),
                  ],
                ),
                Text(set, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                Text(equipo, style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
