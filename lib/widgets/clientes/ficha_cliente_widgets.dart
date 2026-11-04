import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Recuadro "HEX-CRM // V24 — Alta Administrativa de Titular".
class AltaTitularBanner extends StatelessWidget {
  const AltaTitularBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLow,
        borderRadius: AppRadius.sm,
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Dot(size: 8, color: AppColors.accentBright),
              const SizedBox(width: 6),
              Expanded(child: Text('REGISTRO DE CLIENTES', style: AppText.sans(16, weight: FontWeight.w600, letterSpacing: 1.5))),
              Tag(label: 'EN LÍNEA', background: AppColors.surfaceHigh, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  style: AppText.mono(15, color: AppColors.onSurface, letterSpacing: 1)),
            ],
          ),
          const SizedBox(height: 10),
          Text('Alta Administrativa de Titular', style: AppText.sans(20, weight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            'Registro parametrizado para emisión inmediata de órdenes de servicio, minutas contractuales y agenda técnica en set.',
            style: AppText.sans(18, color: AppColors.onSurfaceVariant, lineHeight: 30),
          ),
        ],
      ),
    );
  }
}

/// Selector C.C. / N.I.T. / C.E. de tipo de documento.
class TipoDocumentoSelector extends StatelessWidget {
  const TipoDocumentoSelector({super.key, required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  static const tipos = ['C.C.', 'N.I.T.', 'C.E. / PAS'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, t) in tipos.indexed) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: GestureDetector(
              onTap: () => onSelect(i),
              child: Container(
                height: 46,
                alignment: Alignment.center,
                color: i == selected ? Colors.black : AppColors.surfaceHigh,
                child: Text(t,
                    style: AppText.sans(16, weight: FontWeight.w500, color: i == selected ? Colors.white : AppColors.onSurface)),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Aviso legal de tratamiento de datos (Ley 1581 de 2012).
class HabeasDataNota extends StatelessWidget {
  const HabeasDataNota({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.sm,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SvgIcon('ficha_cliente/habeas.svg', width: 14.7, height: 20.3),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HABEAS DATA & LEY 1581 DE 2012', style: AppText.sans(16, weight: FontWeight.w700, letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(
                  'Los datos ingresados se guardan cifrados y solo se usan para facturación, '
                  'contratos de derechos de autor y seguimiento fiscal.',
                  style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 26),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
