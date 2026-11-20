import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class SaludoAdmin extends StatelessWidget {
  const SaludoAdmin({super.key, required this.fecha, this.saludo = 'Hola'});

  final String saludo;

  final String fecha;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text('$saludo,\nAdministrador',
                    style: AppText.sans(28, weight: FontWeight.w700, color: Colors.black, lineHeight: 36, letterSpacing: -0.7)),
                const SizedBox(width: 8),
                const SvgIcon('inicio/sparkle_y2k.svg', width: 18.48, height: 20),
              ],
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 4, 26, 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: AppRadius.xs,
                boxShadow: AppShadows.soft,
              ),
              child: Row(
                children: [
                  const Dot(size: 8),
                  const SizedBox(width: 4),
                  Text('EN\nVIVO',
                      style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 3.5),
        IconoTexto(const SvgIcon('inicio/calendar.svg', width: 12, height: 13.333), fecha,
            estilo: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
      ],
    );
  }
}
