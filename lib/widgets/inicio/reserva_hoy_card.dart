import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Próxima reserva del día, destacada con barra de acento y acciones.
class ReservaDestacadaCard extends StatelessWidget {
  const ReservaDestacadaCard({
    super.key,
    required this.cliente,
    required this.servicio,
    required this.horario,
    required this.fotografo,
    required this.precio,
    this.onDetalles,
    this.onIniciar,
  });

  final String cliente;
  final String servicio;
  final String horario;
  final String fotografo;

  /// Precio ya formateado, con moneda.
  final String precio;
  final VoidCallback? onDetalles;
  final VoidCallback? onIniciar;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      accentBar: true,
      shadow: AppShadows.medium,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(cliente, style: AppText.sans(16, weight: FontWeight.w600, color: Colors.black, lineHeight: 24)),
                      const SizedBox(width: 6),
                      const SvgIcon('inicio/sparkle_small.svg', width: 14),
                    ],
                  ),
                  Text(servicio,
                      style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                ],
              ),
              Tag(
                label: 'Programada',
                leading: const Dot(size: 8),
                style: AppText.sans(12, weight: FontWeight.w600, color: Colors.black, lineHeight: 18),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconoTexto(const SvgIcon('inicio/clock.svg', width: 15), horario,
                    estilo: AppText.sans(14, weight: FontWeight.w600, color: Colors.black, lineHeight: 18),
                    separacion: 8),
                IconoTexto(const SvgIcon('inicio/person.svg', width: 13.333), fotografo,
                    estilo: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(precio,
                  style: AppText.sans(16, weight: FontWeight.w700, color: Colors.black, lineHeight: 24, letterSpacing: -0.4)),
              Row(
                children: [
                  _BotonChico(
                    'Detalles',
                    const SvgIcon('inicio/eye.svg', width: 14.667, height: 10),
                    dark: false,
                    onTap: onDetalles,
                  ),
                  const SizedBox(width: 8),
                  _BotonChico(
                    'Iniciar',
                    const SvgIcon('inicio/play.svg', width: 7.333, height: 9.333),
                    dark: true,
                    onTap: onIniciar,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reserva del día (programada o ya realizada).
class ReservaHoyCard extends StatelessWidget {
  const ReservaHoyCard({
    super.key,
    required this.cliente,
    required this.servicio,
    required this.horario,
    required this.fotografo,
    required this.precio,
    this.realizada = false,
    this.onGestionar,
  });

  final String cliente;
  final String servicio;
  final String horario;
  final String fotografo;

  /// Precio ya formateado, con moneda.
  final String precio;
  final bool realizada;
  final VoidCallback? onGestionar;

  @override
  Widget build(BuildContext context) {
    final muted = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);
    final card = HexCard(
      color: realizada ? AppColors.surfaceFaded : Colors.white,
      shadow: realizada ? AppShadows.hairline : AppShadows.soft,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cliente, style: AppText.sans(16, weight: FontWeight.w600, color: Colors.black, lineHeight: 24)),
                  Text(servicio, style: muted),
                ],
              ),
              realizada
                  ? Tag(
                      label: 'Realizada',
                      gap: 4,
                      background: AppColors.surfaceHigh,
                      leading: const SvgIcon('inicio/done.svg', width: 12.5),
                      style: AppText.sans(12, weight: FontWeight.w600, color: Colors.black, lineHeight: 18),
                    )
                  : Tag(
                      label: 'Programada',
                      leading: const Dot(),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      style: AppText.sans(12, color: Colors.black, lineHeight: 18),
                    ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconoTexto(const SvgIcon('inicio/clock_small.svg', width: 13.333), horario, estilo: muted),
                IconoTexto(const SvgIcon('inicio/person_small.svg', width: 13.333), fotografo, estilo: muted),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                precio,
                style: realizada
                    ? AppText.sans(16, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 24)
                    : AppText.sans(16, weight: FontWeight.w700, color: Colors.black, lineHeight: 24),
              ),
              if (realizada)
                IconoTexto(const SvgIcon('inicio/raw.svg', width: 13.333), 'Archivos en RAW',
                    estilo: AppText.sans(14, color: AppColors.outline, lineHeight: 18), separacion: 4)
              else
                Material(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadius.xs,
                  child: InkWell(
                    borderRadius: AppRadius.xs,
                    onTap: onGestionar,
                    child: Container(
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: IconoTexto(const SvgIcon('inicio/tune.svg', width: 12), 'Gestionar',
                          estilo: AppText.sans(14, lineHeight: 18), separacion: 4),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
    return realizada ? Opacity(opacity: 0.9, child: card) : card;
  }
}

class _BotonChico extends StatelessWidget {
  const _BotonChico(this.label, this.icon, {required this.dark, this.onTap});

  final String label;
  final Widget icon;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: dark ? Colors.black : AppColors.surfaceContainer,
      borderRadius: AppRadius.xs,
      child: InkWell(
        borderRadius: AppRadius.xs,
        onTap: onTap ?? () {},
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 4),
              Text(label, style: AppText.sans(14, color: dark ? Colors.white : AppColors.onSurface, lineHeight: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
