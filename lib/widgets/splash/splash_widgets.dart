import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

/// Marco de visor de cámara: esquinas, exposición, mira central y "REC".
class SplashVisor extends StatelessWidget {
  const SplashVisor({super.key});

  @override
  Widget build(BuildContext context) {
    final mono = AppText.mono(10, lineHeight: 24, letterSpacing: 1);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SvgIcon('splash/corner_tl.svg', width: 24),
              Text.rich(TextSpan(style: mono, children: [
                const TextSpan(text: 'ISO 100 '),
                TextSpan(text: '●', style: mono.copyWith(color: AppColors.accent)),
                const TextSpan(text: ' 1/250s f/2.8'),
              ])),
              const SvgIcon('splash/corner_tr.svg', width: 24),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(width: 128, height: 1, color: AppColors.outlineFaint),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 12,
                height: 12,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.surfaceHighestFaded, borderRadius: AppRadius.lg),
                child: const Dot(size: 4),
              ),
              Container(width: 128, height: 1, color: AppColors.outlineFaint),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SvgIcon('splash/corner_bl.svg', width: 24),
              Text('REC [● RAW UNCOMPRESSED]', style: AppText.mono(9, color: AppColors.outline, lineHeight: 24, letterSpacing: 0.9)),
              const SvgIcon('splash/corner_br.svg', width: 24),
            ],
          ),
        ],
      ),
    );
  }
}

/// "SYS.ONLINE" y la sede "BOG-STD01".
class SplashTelemetria extends StatelessWidget {
  const SplashTelemetria({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Tag(
          label: 'EN LÍNEA',
          leading: const Dot(),
          gap: 4,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          style: AppText.mono(11, color: AppColors.onSurface, lineHeight: 24, letterSpacing: 0.55),
        ),
        IconoTexto(const SvgIcon('splash/star.svg', width: 16), 'BOGOTÁ',
            estilo: AppText.mono(11, lineHeight: 24, letterSpacing: 1.1), separacion: 4),
      ],
    );
  }
}

/// Logo en marcos concéntricos, nombre del estudio y versión del motor.
class SplashMarca extends StatelessWidget {
  const SplashMarca({super.key});

  @override
  Widget build(BuildContext context) {
    Widget tick(double w, double h) => Container(width: w, height: h, color: AppColors.outlineVariant);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 176,
          height: 176,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(color: AppColors.surfaceHighGhost, borderRadius: AppRadius.lg),
              ),
              Container(
                width: 144,
                height: 144,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: AppRadius.lg,
                  boxShadow: AppShadows.soft,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 112,
                      height: 112,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: AppRadius.lg,
                        boxShadow: AppShadows.medium,
                      ),
                      child: Image.asset('assets/images/logo_mark.png', fit: BoxFit.contain),
                    ),
                    Positioned(top: 8, child: tick(4, 8)),
                    Positioned(bottom: 8, child: tick(4, 8)),
                    Positioned(left: 8, child: tick(8, 4)),
                    Positioned(right: 8, child: tick(8, 4)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text('HEXLENS STUDIO',
            textAlign: TextAlign.center,
            style: AppText.sans(28, weight: FontWeight.w700, color: Colors.black, lineHeight: 36, letterSpacing: -0.7)),
        const SizedBox(height: 8),
        Text('SISTEMA OPERATIVO & GESTIÓN DE\nPRODUCCIÓN FOTOGRÁFICA',
            textAlign: TextAlign.center,
            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.35)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(color: AppColors.ink, borderRadius: AppRadius.xs),
          child: IconoTexto(const SvgIcon('splash/terminal.svg', width: 11.667, height: 9.333), 'INICIANDO',
              estilo: AppText.mono(11, color: AppColors.surfaceContainer, lineHeight: 24, letterSpacing: 1.1),
              separacion: 4, compacto: true),
        ),
      ],
    );
  }
}

/// Tarjeta de carga con porcentaje, barra y estado de los servicios.
class SplashCarga extends StatelessWidget {
  const SplashCarga({super.key, required this.progreso});

  /// 0–1.
  final double progreso;

  @override
  Widget build(BuildContext context) {
    final sep = Text('|', style: AppText.mono(10, color: AppColors.outlineVariant, lineHeight: 24));
    return HexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SvgIcon('splash/sync.svg', width: 10.667),
              const SizedBox(width: 4),
              Expanded(
                child: Text('Cargando catálogos y agenda en set...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(12, weight: FontWeight.w500, lineHeight: 24)),
              ),
              Text('${(progreso * 100).round()}%',
                  style: AppText.mono(12, weight: FontWeight.w700, color: Colors.black, lineHeight: 24)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: AppRadius.lg,
            child: LinearProgressIndicator(
              value: progreso,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainer,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _lectura('●', AppColors.accent, 'FACTURACIÓN:\nLISTA'),
              sep,
              _lectura('■', AppColors.onSurface, 'ARCHIVOS:\nLISTOS'),
              sep,
              _lectura('▲', AppColors.accent, 'SESIÓN:\nSEGURA'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _lectura(String marca, Color color, String label) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(marca, style: AppText.mono(10, weight: FontWeight.w700, color: color, lineHeight: 24)),
        const SizedBox(width: 4),
        Text(label, style: AppText.mono(10, lineHeight: 24)),
      ],
    );
  }
}

/// Créditos y edición al pie del splash.
class SplashPie extends StatelessWidget {
  const SplashPie({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('© 2024 HEXLENS STUDIO LABS • BOGOTÁ, COLOMBIA',
            textAlign: TextAlign.center,
            style: AppText.mono(11, color: AppColors.outline, lineHeight: 24, letterSpacing: 0.55)),
      ],
    );
  }
}
