import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class NuevaEspecialidadCabecera extends StatelessWidget {
  const NuevaEspecialidadCabecera({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(26, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconoTexto(const Icon(Icons.circle, size: 9, color: AppColors.accent), 'CATÁLOGO DE ESPECIALIDADES',
              estilo: AppText.sans(15, weight: FontWeight.w600, color: AppColors.accent, letterSpacing: 0.8),
              separacion: 8, ajuste: FlexFit.loose),
          Text('Nueva Especialidad', style: AppText.sans(26, weight: FontWeight.w700, lineHeight: 34)),
          Text('Gestión de categoría técnica y disponibilidad de servicios',
              style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
        ],
      ),
    );
  }
}

