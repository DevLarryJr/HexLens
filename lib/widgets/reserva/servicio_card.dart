import 'package:flutter/material.dart';

import '../../models/servicio.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../hex_widgets.dart';

/// Círculo de selección: negro con check si está seleccionado, gris si no.
class SelectCheck extends StatelessWidget {
  const SelectCheck({super.key, required this.selected, this.size = 24});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? Colors.black : AppColors.surfaceHigh,
        borderRadius: AppRadius.lg,
      ),
      child: selected ? const SvgIcon('servicio/check_small.svg', width: 10.867, height: 8.017) : null,
    );
  }
}

/// Tarjeta de servicio del paso 2 de la reserva. Seleccionada muestra la barra
/// de acento, las fotos de muestra y el precio destacado.
class ServicioCard extends StatelessWidget {
  const ServicioCard({super.key, required this.servicio, required this.selected, this.onTap});

  final Servicio servicio;
  final bool selected;
  final VoidCallback? onTap;

  static const _fotos = ['servicio_1.jpg', 'servicio_2.jpg', 'servicio_3.jpg'];

  @override
  Widget build(BuildContext context) {
    final s = servicio;
    final inset = EdgeInsets.only(left: selected ? 8 : 0);
    final precio = formatCop(s.precio);

    final card = HexCard(
      accentBar: selected,
      shadow: selected ? AppShadows.medium : AppShadows.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: inset,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(s.nombre, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                          if (s.popular)
                            Tag(
                              label: 'POPULAR',
                              gap: 2,
                              background: AppColors.accentContainer,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              leading: const SvgIcon('servicio/popular.svg', width: 11.917),
                              style: AppText.sans(14,
                                  weight: FontWeight.w700, color: AppColors.onAccentContainer, lineHeight: 18),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text('${s.categoria} • ${s.duracion}',
                          style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                    ],
                  ),
                ),
                SelectCheck(selected: selected),
              ],
            ),
          ),
          if (selected) ...[
            const SizedBox(height: 12),
            Padding(
              padding: inset,
              child: Row(
                children: [
                  for (var i = 0; i < _fotos.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadius.sm,
                        child: Image.asset('assets/images/${_fotos[i]}', height: 64, fit: BoxFit.cover),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Padding(
            padding: inset,
            child: Text(s.descripcion,
                style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 24)),
          ),
          const SizedBox(height: 8),
          selected ? _precioDestacado(precio) : _precio(precio),
        ],
      ),
    );

    return GestureDetector(
      onTap: onTap,
      child: selected ? card : Opacity(opacity: 0.9, child: card),
    );
  }

  Widget _precioDestacado(String precio) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Precio', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          Text.rich(TextSpan(children: [
            TextSpan(
                text: '$precio ',
                style: AppText.sans(28,
                    weight: FontWeight.w700, color: Colors.black, lineHeight: 32, letterSpacing: -0.84)),
            TextSpan(
                text: 'COP',
                style: AppText.sans(14, weight: FontWeight.w500, color: Colors.black, lineHeight: 18)),
          ])),
        ],
      ),
    );
  }

  Widget _precio(String precio) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Precio', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
          Text('$precio COP', style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
        ],
      ),
    );
  }
}
