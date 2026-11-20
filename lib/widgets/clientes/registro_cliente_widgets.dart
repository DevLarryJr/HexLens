import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_form.dart';
import '../hex_widgets.dart';

class RegistroClienteCabecera extends StatelessWidget {
  const RegistroClienteCabecera({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: AppColors.surfaceHigh,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SvgIcon('reg_cliente/hex.svg', width: 14, height: 14),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('DIRECTORIO DE CLIENTES',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.sans(15, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, letterSpacing: 0.8)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text('Nuevo Cliente', style: AppText.sans(24, weight: FontWeight.w700)),
            const SizedBox(width: 8),
            const Icon(Icons.circle, size: 8, color: AppColors.accent),
          ],
        ),
        const SizedBox(height: 6),
        Text('Ficha digital de vinculación directa para agenda, facturación y entrega de galería fotográfica.',
            style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 24)),
      ],
    );
  }
}

class HabeasDataBreve extends StatelessWidget {
  const HabeasDataBreve({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoBox(
      leading: const SvgIcon('reg_cliente/habeas.svg', width: 13.3, height: 18.7),
      iconColor: AppColors.accent,
      background: AppColors.surfaceHighFaded,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PROTECCIÓN DE DATOS · LEY 1581', style: AppText.sans(16, weight: FontWeight.w700)),
          Text(
              'Datos custodiados para uso exclusivo de confirmación de llamado a set, factura DIAN y acceso cifrado a galería RAW.',
              style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 26)),
        ],
      ),
    );
  }
}

