import 'package:flutter/material.dart';

import '../../models/servicio.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../hex_chips.dart';
import '../hex_widgets.dart';

/// "Servicios y Tarifas": total activo, botón "Nuevo" y aviso de precios en COP.
class ServiciosCabecera extends StatelessWidget {
  const ServiciosCabecera({super.key, required this.activos, this.onNuevo});

  final int activos;
  final VoidCallback? onNuevo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Servicios y Tarifas',
                          style: AppText.sans(20, weight: FontWeight.w700, lineHeight: 28, letterSpacing: -0.5)),
                      const SizedBox(width: 4),
                      const SvgIcon('servicios/sparkle.svg', width: 16),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Dot(size: 7),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text('$activos SERVICIOS ACTIVOS',
                            style: AppText.sans(14,
                                weight: FontWeight.w500,
                                color: AppColors.onSurfaceVariant,
                                lineHeight: 18,
                                letterSpacing: 0.35)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 104,
              child: HexButton(
                label: 'Nuevo',
                height: 44,
                gap: 6,
                onPressed: onNuevo,
                leading: const SvgIcon('servicios/plus.svg', width: 11.667),
                textStyle: AppText.sans(16, weight: FontWeight.w600, color: Colors.white, lineHeight: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: AppRadius.sm,
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              Container(
                width: 26,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.sm),
                child: const SvgIcon('servicios/aperture.svg', width: 13.5, height: 15.75),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tarifas vigentes', style: AppText.sans(14, weight: FontWeight.w700, lineHeight: 17.5)),
                    Text('Precios base con IVA y derechos de uso incluidos',
                        style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 17.5)),
                  ],
                ),
              ),
              Tag(
                label: 'COP',
                background: AppColors.accentContainer,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                style: AppText.sans(14, weight: FontWeight.w700, color: AppColors.onAccentContainer, lineHeight: 18),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Chip de categoría con su número de servicios.
class CategoriaChip extends StatelessWidget {
  const CategoriaChip({super.key, required this.label, required this.count, required this.selected, this.onTap});

  final String label;
  final int count;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: HexChip(
        label: label,
        selected: selected,
        onTap: onTap,
        height: 36,
        radius: 4,
        shadow: AppShadows.soft,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        style: AppText.sans(14, weight: selected ? FontWeight.w600 : FontWeight.w500, lineHeight: 18),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceHighest : AppColors.surfaceHigh,
            borderRadius: AppRadius.lg,
          ),
          child: Text('$count',
              style: AppText.sans(11, weight: selected ? FontWeight.w700 : FontWeight.w600, lineHeight: 18)),
        ),
      ),
    );
  }
}

/// Tarjeta de un servicio del catálogo con su tarifa.
class ServicioCatalogoCard extends StatelessWidget {
  const ServicioCatalogoCard({super.key, required this.servicio, this.destacado = false, this.onEditar});

  final Servicio servicio;

  /// Botón "Editar Tarifa" en negro.
  final bool destacado;
  final VoidCallback? onEditar;

  @override
  Widget build(BuildContext context) {
    final s = servicio;
    final muted = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);
    return HexCard(
      shadow: AppShadows.hairline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(s.codigo,
                            style: AppText.sans(14, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 18)),
                        const SizedBox(width: 6),
                        const Dot(size: 4, color: AppColors.outlineVariant),
                        const SizedBox(width: 6),
                        Text(s.categoria.toUpperCase(),
                            style: AppText.sans(14,
                                weight: FontWeight.w600,
                                color: AppColors.onSurfaceVariant,
                                lineHeight: 18,
                                letterSpacing: 0.7)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(s.nombre, style: AppText.sans(16, weight: FontWeight.w700, lineHeight: 24)),
                  ],
                ),
              ),
              Tag(
                label: 'Activo',
                leading: const Dot(size: 8),
                radius: 4,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(s.ficha ?? s.descripcion, style: muted),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconoTexto(const SvgIcon('servicios/timer.svg', width: 16.667), '${s.duracionMin} MIN',
                    estilo: AppText.sans(16, weight: FontWeight.w700, lineHeight: 20), separacion: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('TARIFA OFICIAL', style: muted),
                    Text.rich(TextSpan(children: [
                      TextSpan(
                          text: '${formatCop(s.precio)} ',
                          style: AppText.sans(20, weight: FontWeight.w700, lineHeight: 25, letterSpacing: -0.2)),
                      TextSpan(text: 'COP', style: AppText.sans(13, color: AppColors.onSurfaceVariant, lineHeight: 16.25)),
                    ])),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconoTexto(const SvgIcon('servicios/lock.svg', width: 10.667, height: 14), 'Esquema restringido',
                  estilo: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 18), separacion: 4),
              SizedBox(
                width: 136,
                child: HexButton(
                  label: 'Editar Tarifa',
                  height: 40,
                  gap: 6,
                  shadow: null,
                  background: destacado ? Colors.black : AppColors.surfaceHighest,
                  onPressed: onEditar,
                  leading: SvgIcon(destacado ? 'servicios/edit_white.svg' : 'servicios/edit.svg', width: 12),
                  textStyle: AppText.sans(14,
                      weight: FontWeight.w600, color: destacado ? Colors.white : AppColors.onSurface, lineHeight: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "REGLA DE INTEGRIDAD HEXLENS".
class IntegridadNota extends StatelessWidget {
  const IntegridadNota({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconoTexto(const SvgIcon('servicios/shield.svg', width: 12, height: 15), 'REGLA DE INTEGRIDAD HEXLENS',
              estilo: AppText.sans(14,
                      weight: FontWeight.w700, color: AppColors.accent, lineHeight: 18, letterSpacing: 0.35)),
          const SizedBox(height: 4),
          Text(
            'La denominación técnica y categoría del servicio se mantienen bloqueadas para '
            'garantizar consistencia contractual y trazabilidad en informes financieros.',
            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18),
          ),
        ],
      ),
    );
  }
}
