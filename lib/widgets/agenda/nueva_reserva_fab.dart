import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class NuevaReservaFab extends StatelessWidget {
  const NuevaReservaFab({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(borderRadius: AppRadius.lg, boxShadow: AppShadows.large),
      child: Material(
        color: AppColors.accent,
        borderRadius: AppRadius.lg,
        child: InkWell(
          borderRadius: AppRadius.lg,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: IconoTexto(const SvgIcon('agenda/add_circle.svg', width: 20), '+ Nueva reserva',
                estilo: AppText.sans(16,
                        weight: FontWeight.w600, color: Colors.white, lineHeight: 24, letterSpacing: -0.4), separacion: 8),
          ),
        ),
      ),
    );
  }
}
