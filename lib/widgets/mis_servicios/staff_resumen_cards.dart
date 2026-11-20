import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class ModoStaffBanner extends StatelessWidget {
  const ModoStaffBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.sm,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.lg),
            child: const SvgIcon('mis_servicios/terminal.svg', width: 11.7, height: 9.3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text.rich(TextSpan(
              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18),
              children: [
                TextSpan(text: 'Modo fotógrafo: ', style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18)),
                const TextSpan(text: 'Sesiones asignadas a tu cuenta técnica.'),
              ],
            )),
          ),
          const SvgIcon('mis_servicios/radio.svg', width: 13.3, height: 13.3),
        ],
      ),
    );
  }
}

class SaludoStaffCard extends StatelessWidget {
  const SaludoStaffCard({
    super.key,
    required this.nombre,
    required this.foto,
    required this.id,
    required this.especialidad,
    required this.camara,
    this.saludo = 'Hola',
  });

  final String nombre;

  final String saludo;

  final String foto;
  final String id;
  final String especialidad;

  final String camara;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          const Positioned(
            right: -24,
            bottom: -24,
            child: Icon(Icons.info_outline, size: 110, color: Color(0x14000000)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.sm,
                          child: Image.asset('assets/images/$foto',
                              width: 52, height: 60, fit: BoxFit.cover, alignment: Alignment.topCenter),
                        ),
                        Positioned(
                          right: -6,
                          bottom: -6,
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: AppColors.accentBright,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const SvgIcon('mis_servicios/star.svg', width: 9.2, height: 8.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text('$saludo, $nombre',
                                    style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 26)),
                              ),
                              const SizedBox(width: 4),
                              const SvgIcon('mis_servicios/sparkle.svg', width: 14),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Tag(label: 'ID: $id', background: AppColors.surfaceHigh, padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  style: AppText.sans(13, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                              const SizedBox(width: 8),
                              Text('• $especialidad',
                                  style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Tag(label: camara, background: Colors.black, radius: 8,
                        style: AppText.mono(13, weight: FontWeight.w700, color: Colors.white, lineHeight: 18)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Mis Servicios\nRealizados',
                    style: AppText.sans(30, weight: FontWeight.w700, lineHeight: 36, letterSpacing: -0.6)),
                const SizedBox(height: 6),
                Text('Historial de sesiones fotográficas ejecutadas y en curso asignadas a tu cámara.',
                    style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ContadorServiciosCard extends StatelessWidget {
  const ContadorServiciosCard({super.key, required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.sm),
            child: const SvgIcon('mis_servicios/servicios.svg', width: 20, height: 21),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$total', style: AppText.sans(26, weight: FontWeight.w700, lineHeight: 30)),
              Text('Servicios este período', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

class ProximaSesionCard extends StatelessWidget {
  const ProximaSesionCard({super.key, required this.titulo, required this.cliente, required this.detalle});

  final String titulo;
  final String cliente;

  final String detalle;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      color: AppColors.ink,
      radius: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Dot(size: 6, color: Color(0xFFFF8A80)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(titulo,
                    style: AppText.sans(14, weight: FontWeight.w600, color: Colors.white, lineHeight: 18)),
              ),
              const SvgIcon('mis_servicios/timer.svg', width: 13.5, height: 15.8),
            ],
          ),
          const SizedBox(height: 10),
          Text(cliente, style: AppText.sans(16, weight: FontWeight.w600, color: Colors.white, lineHeight: 22)),
          Text(detalle, style: AppText.sans(14, color: AppColors.darkMuted, lineHeight: 20)),
        ],
      ),
    );
  }
}
