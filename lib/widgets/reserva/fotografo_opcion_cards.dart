import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';
import 'servicio_card.dart';

/// Opción "Asignar cualquiera disponible" del paso 2 de la reserva.
class AutoAsignarCard extends StatelessWidget {
  const AutoAsignarCard({super.key, required this.selected, this.onTap});

  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: HexCard(
        accentBar: selected,
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accentBright,
                borderRadius: AppRadius.sm,
                boxShadow: AppShadows.soft,
              ),
              child: const SvgIcon('servicio/bolt.svg', width: 16, height: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Asignar cualquiera disponible',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                  Text('El sistema asigna por carga horaria',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                ],
              ),
            ),
            SelectCheck(selected: selected, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Fotógrafo disponible y recomendado para el servicio elegido.
class FotografoRecomendadoCard extends StatelessWidget {
  const FotografoRecomendadoCard({
    super.key,
    required this.nombre,
    required this.foto,
    required this.detalle,
    required this.disponibilidad,
    required this.score,
    required this.equipo,
    required this.selected,
    this.onTap,
  });

  final String nombre;

  /// Archivo dentro de `assets/images/`.
  final String foto;

  /// Ej.: "Retratos • Comisión: 30%".
  final String detalle;

  /// Ej.: "Disponible para Retrato profesional".
  final String disponibilidad;
  final String score;
  final String equipo;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: HexCard(
        accentBar: selected,
        shadow: selected ? AppShadows.medium : AppShadows.soft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.sm,
                        child: Image.asset('assets/images/$foto', width: 48, height: 48, fit: BoxFit.cover),
                      ),
                      Positioned(
                        right: -4,
                        bottom: -4,
                        child: Container(
                          width: 16,
                          height: 16,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: AppRadius.lg,
                          ),
                          child: const SvgIcon('servicio/badge_star.svg', width: 9.167),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                        const SizedBox(height: 6),
                        Tag(
                          label: 'Recomendada',
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18),
                        ),
                        Text(detalle,
                            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                      ],
                    ),
                  ),
                  SelectCheck(selected: selected),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
              child: Row(
                children: [
                  const Dot(size: 8),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(disponibilidad,
                        style: AppText.sans(14,
                            weight: FontWeight.w500, color: AppColors.accent, lineHeight: 18)),
                  ),
                  const SizedBox(width: 12),
                  Text('Score\n$score★',
                      style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconoTexto(const SvgIcon('servicio/lens.svg', width: 13.333), equipo,
                  estilo: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18), separacion: 4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fotógrafo que no puede tomar el servicio (atenuado, foto en grises).
class FotografoNoDisponibleCard extends StatelessWidget {
  const FotografoNoDisponibleCard({
    super.key,
    required this.nombre,
    required this.foto,
    required this.especialidad,
    required this.motivo,
  });

  final String nombre;

  /// Archivo dentro de `assets/images/`.
  final String foto;
  final String especialidad;
  final String motivo;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: HexCard(
        color: AppColors.surfaceLow,
        shadow: null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: AppRadius.sm,
                  child: ColorFiltered(
                    colorFilter: AppFilters.grayscale,
                    child: Image.asset('assets/images/$foto', width: 48, height: 48, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(nombre, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                          Tag(
                            label: 'No disponible',
                            background: AppColors.surfaceHigh,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18),
                          ),
                        ],
                      ),
                      Text(especialidad,
                          style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                    ],
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceHighest,
                    borderRadius: AppRadius.lg,
                  ),
                  child: const SvgIcon('servicio/block.svg', width: 11.667),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 3),
                  child: SvgIcon('servicio/error.svg', width: 11.667),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(motivo, style: AppText.sans(14, color: AppColors.error, lineHeight: 18)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
