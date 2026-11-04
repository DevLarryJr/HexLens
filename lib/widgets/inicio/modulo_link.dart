import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Acceso a un módulo de gestión (Especialidades, Servicios, Fotógrafos…).
class ModuloLink extends StatelessWidget {
  const ModuloLink({
    super.key,
    required this.icon,
    required this.iconWidth,
    required this.iconHeight,
    required this.titulo,
    required this.subtitulo,
    this.onTap,
  });

  /// Ruta dentro de `assets/icons/`.
  final String icon;
  final double iconWidth;
  final double iconHeight;
  final String titulo;
  final String subtitulo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 72),
      decoration: BoxDecoration(color: Colors.white, borderRadius: AppRadius.sm, boxShadow: AppShadows.soft),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.sm,
          onTap: onTap ?? () {},
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.xs),
                      child: SvgIcon(icon, width: iconWidth, height: iconHeight),
                    ),
                    const SvgIcon('inicio/arrow_outward.svg', width: 10),
                  ],
                ),
                const SizedBox(height: 8),
                Text(titulo, style: AppText.sans(16, weight: FontWeight.w600, color: Colors.black, lineHeight: 20)),
                const SizedBox(height: 2),
                Text(subtitulo, style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Estado del equipo de captura del estudio.
class HardwareStatusCard extends StatelessWidget {
  const HardwareStatusCard({super.key, required this.titulo, required this.detalle});

  /// Ej.: "Estudio A — SONY α7 IV".
  final String titulo;
  final String detalle;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.xs),
            child: const SvgIcon('inicio/camera_hw.svg', width: 18.333),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: AppText.sans(14, weight: FontWeight.w600, color: Colors.black, lineHeight: 14)),
                const SizedBox(height: 4),
                Text(detalle, style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
          const Dot(size: 10),
        ],
      ),
    );
  }
}
