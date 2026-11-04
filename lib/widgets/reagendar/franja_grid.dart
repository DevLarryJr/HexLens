import 'package:flutter/material.dart';

import '../../models/franja_horaria.dart';
import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Grilla de franjas horarias en dos columnas, con leyenda arriba y la
/// franja elegida abajo.
class FranjaGrid extends StatelessWidget {
  const FranjaGrid({
    super.key,
    required this.franjas,
    required this.seleccion,
    required this.resumen,
    required this.cabina,
    this.onSelect,
  });

  final List<FranjaHoraria> franjas;
  final int seleccion;

  /// Ej.: "Franja seleccionada: 11:30 AM (45 min)".
  final String resumen;

  /// Ej.: "Cabina 02\nLibre".
  final String cabina;
  final ValueChanged<int>? onSelect;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.surfaceHigh)),
            ),
            child: const Row(
              children: [
                _Leyenda(Colors.black, 'Seleccionado'),
                SizedBox(width: 16),
                _Leyenda(AppColors.surfaceHigh, 'Disponible'),
                SizedBox(width: 16),
                _Leyenda(AppColors.surfaceLow, 'Ocupado', opacity: 0.4),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var r = 0; r * 2 < franjas.length; r++) ...[
            if (r > 0) const SizedBox(height: 8),
            Row(
              children: [
                Expanded(child: _slot(r * 2)),
                const SizedBox(width: 8),
                Expanded(child: r * 2 + 1 < franjas.length ? _slot(r * 2 + 1) : const SizedBox()),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(resumen, style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                ),
                Text(
                  cabina,
                  style: AppText.sans(12, weight: FontWeight.w600, color: Colors.black, lineHeight: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _slot(int i) {
    final franja = franjas[i];
    final selected = i == seleccion;
    final disabled = !franja.disponible;
    return GestureDetector(
      onTap: disabled ? null : () => onSelect?.call(i),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.black : AppColors.surfaceLow,
          borderRadius: AppRadius.xs,
          boxShadow: selected ? AppShadows.medium : null,
        ),
        child: Row(
          children: [
            if (selected) ...[const SvgIcon('reagendar/check_circle.svg', width: 15), const SizedBox(width: 6)],
            // La hora en una línea ("11:30 AM"); si no cabe junto a la etiqueta se reduce un poco en vez de partirse.
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  franja.hora,
                  maxLines: 1,
                  style: AppText.sans(
                    16,
                    weight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: selected ? Colors.white : (disabled ? AppColors.disabled : AppColors.onSurface),
                    lineHeight: 24,
                    decoration: disabled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
            // La franja elegida ya se distingue por el fondo negro y el check; sin la etiqueta "ELEGIDO"
            // la hora cabe completa.
            if (disabled) ...[
              const SizedBox(width: 6),
              Text(
                franja.bloqueo!,
                style: AppText.sans(11, color: AppColors.disabled, lineHeight: 16.5, letterSpacing: 0.55),
              ),
            ] else if (!selected)
              const Dot(size: 8, color: AppColors.neutralDot),
          ],
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda(this.color, this.label, {this.opacity = 1});

  final Color color;
  final String label;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Opacity(
          opacity: opacity,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, borderRadius: AppRadius.xs),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 18)),
      ],
    );
  }
}
