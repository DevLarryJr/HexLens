import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class ContextoBloqueado extends StatelessWidget {
  const ContextoBloqueado({
    super.key,
    required this.auditoria,
    required this.orden,
    required this.cliente,
    required this.documento,
    required this.telefono,
    required this.servicio,
    required this.precio,
    required this.duracion,
    required this.cabina,
  });

  final String auditoria;
  final String orden;
  final String cliente;
  final String documento;
  final String telefono;
  final String servicio;

  final String precio;
  final String duracion;
  final String cabina;

  @override
  Widget build(BuildContext context) {
    final muted = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Dot(size: 7),
                const SizedBox(width: 4),
                Text(
                  'REAGENDAR\nRESERVA',
                  style: AppText.sans(
                    14,
                    weight: FontWeight.w600,
                    color: AppColors.accent,
                    lineHeight: 18,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
            if (auditoria.isNotEmpty)
              Tag(
                label: auditoria,
                background: AppColors.surfaceHighest,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 18),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Reagendar Sesión Fotográfica',
          style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 28, letterSpacing: -0.2),
        ),
        const SizedBox(height: 4),
        Text('Elige una nueva fecha, hora y fotógrafo para la sesión.', style: muted),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceLow,
            borderRadius: AppRadius.sm,
            boxShadow: AppShadows.soft,
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 5),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.surfaceHigh)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconoTexto(const SvgIcon('reagendar/lock.svg', width: 10.667, height: 14),
                        '[ NO MODIFICABLE /\nBLOQUEADO ]',
                        estilo: AppText.sans(
                            14,
                            weight: FontWeight.w600,
                            color: AppColors.accent,
                            lineHeight: 18,
                            letterSpacing: 1.4,
                          )),
                    Text(
                      'ORDEN ORIGEN:\n$orden',
                      style: AppText.sans(11, color: AppColors.onSurfaceVariant, lineHeight: 16.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _LockedCard(
                dark: true,
                icon: const SvgIcon('reagendar/person.svg', width: 16.667),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(cliente, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                        Tag(
                          label: 'Recurrente',
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          style: AppText.sans(11, weight: FontWeight.w600, lineHeight: 16.5),
                        ),
                      ],
                    ),
                    Text(documento, style: muted),
                    const SizedBox(height: 2),
                    IconoTexto(const SvgIcon('reagendar/phone.svg', width: 10.5), telefono,
                        estilo: muted, separacion: 4),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _LockedCard(
                dark: false,
                icon: const SvgIcon('reagendar/camera.svg', width: 16.667, height: 15),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            servicio,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          precio,
                          style: AppText.sans(16, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        IconoTexto(const SvgIcon('reagendar/timer.svg', width: 10.5, height: 12.25), duracion,
                            estilo: muted, separacion: 4),
                        IconoTexto(const SvgIcon('reagendar/door.svg', width: 10.5), cabina,
                            estilo: muted, separacion: 4),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SvgIcon('reagendar/info.svg', width: 12.5, height: 14.5),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'El titular y el tipo de servicio están anclados a la factura DIAN original. '
                        'Para alterar el servicio base, cancele esta cita y genere una orden nueva.',
                        style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 15),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LockedCard extends StatelessWidget {
  const _LockedCard({required this.icon, required this.dark, required this.content});

  final Widget icon;
  final bool dark;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xs,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? Colors.black : AppColors.surfaceHigh,
              borderRadius: AppRadius.xs,
            ),
            child: icon,
          ),
          const SizedBox(width: 8),
          Expanded(child: content),
        ],
      ),
    );
  }
}
