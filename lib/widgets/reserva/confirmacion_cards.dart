import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_form.dart';
import '../hex_widgets.dart';

/// Encabezado "PASO 4 DE 4 · Confirmar Reserva · REVISIÓN FINAL" con la barra de progreso.
class ConfirmacionCabecera extends StatelessWidget {
  const ConfirmacionCabecera({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconoTexto(const SvgIcon('confirm/sparkle.svg', width: 12.833), 'PASO 4 DE 4', estilo: AppText.sans(14,
                            weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 1.4), separacion: 4),
                const SizedBox(height: 2),
                Text('Confirmar Reserva',
                    style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 28, letterSpacing: -0.2)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.xs, boxShadow: AppShadows.soft),
              child: Row(
                children: [
                  const Dot(size: 8),
                  const SizedBox(width: 6),
                  Text('REVISIÓN FINAL',
                      style: AppText.sans(14, weight: FontWeight.w600, color: Colors.white, lineHeight: 18, letterSpacing: 0.35)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 3; i++) ...[
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.xs),
                ),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(
              child: Container(
                height: 11,
                decoration: BoxDecoration(color: AppColors.accent, borderRadius: AppRadius.xs),
                alignment: Alignment.centerRight,
                child: const SvgIcon('confirm/step_sparkle.svg', width: 11),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Resumen de la reserva: servicio, titular, horario, fotógrafo y valor total.
class ResumenReservaCard extends StatelessWidget {
  const ResumenReservaCard({
    super.key,
    required this.codigo,
    required this.categoria,
    required this.servicio,
    required this.lugarDuracion,
    required this.clienteIniciales,
    required this.clienteNombre,
    required this.clienteDocumento,
    required this.telefono,
    required this.email,
    required this.fecha,
    required this.horario,
    required this.fotografo,
    required this.comision,
    required this.total,
  });

  final String codigo;

  /// En mayúsculas: "RETRATOS".
  final String categoria;
  final String servicio;

  /// Ej.: "Ciclorama Blanco • 45 min".
  final String lugarDuracion;
  final String clienteIniciales;
  final String clienteNombre;

  /// Ej.: "C.C. 1.025.340.890 (Bogotá D.C.)".
  final String clienteDocumento;
  final String telefono;
  final String email;

  /// Ej.: "Jue, 15 Oct 2026".
  final String fecha;

  /// Ej.: "10:00 AM - 10:45 AM".
  final String horario;
  final String fotografo;

  /// Ej.: "Comisión: 30%".
  final String comision;

  /// Precio formateado sin moneda: "$120.000".
  final String total;

  @override
  Widget build(BuildContext context) {
    final muted = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);
    return HexCard(
      radius: 2,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            color: AppColors.surfaceLow,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconoTexto(const SvgIcon('confirm/receipt.svg', width: 15, height: 16.667), codigo,
                    estilo: AppText.sans(16, weight: FontWeight.w600, color: Colors.black, lineHeight: 24, letterSpacing: -0.4),
                    separacion: 8),
                Tag(
                  label: 'Pendiente',
                  leading: const Dot(),
                  background: AppColors.surfaceHigh,
                  style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.xs),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: AppRadius.xs,
                        child: SizedBox(
                          width: 64,
                          height: 64,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset('assets/images/estudio_a.jpg', fit: BoxFit.cover),
                              Positioned(
                                left: 0,
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  color: AppColors.scrim,
                                  padding: const EdgeInsets.only(top: 8.5, bottom: 4.5),
                                  child: Text('ESTUDIO A',
                                      textAlign: TextAlign.center,
                                      style: AppText.sans(10,
                                          weight: FontWeight.w700, color: Colors.white, lineHeight: 15, letterSpacing: 0.5)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(categoria,
                                    style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18)),
                                const SizedBox(width: 4),
                                const SvgIcon('confirm/sparkle_small.svg', width: 11),
                              ],
                            ),
                            Text(servicio, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                            Text(lugarDuracion, style: muted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                InfoBox(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Titular de la sesión',
                              style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                          IconoTexto(const SvgIcon('confirm/verified.svg', width: 9.333, height: 11.667), 'Verificado',
                              estilo: AppText.sans(14, weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18),
                              separacion: 4),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.lg),
                            child: Text(clienteIniciales,
                                style: AppText.sans(16, weight: FontWeight.w600, color: Colors.white, lineHeight: 24)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(clienteNombre, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                                Text(clienteDocumento, style: muted),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      IconoTexto(const SvgIcon('confirm/phone.svg', width: 10, height: 14.667), telefono,
                          estilo: muted, separacion: 8),
                      const SizedBox(height: 4),
                      IconoTexto(const SvgIcon('confirm/at.svg', width: 13.333), email, estilo: muted, separacion: 8),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _InfoBox('confirm/calendar.svg', 13.5, 15, 'Horario', fecha, Text(horario, style: muted)),
                      const SizedBox(width: 10),
                      _InfoBox(
                        'confirm/camera.svg',
                        15,
                        13.5,
                        'Fotógrafa',
                        fotografo,
                        Text(comision, style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.accent, lineHeight: 18)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _Total(total: total),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox(this.icon, this.w, this.h, this.label, this.value, this.sub);

  final String icon;
  final double w;
  final double h;
  final String label;
  final String value;
  final Widget sub;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InfoBox(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconoTexto(SvgIcon(icon, width: w, height: h), label,
                estilo: AppText.sans(14, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            const SizedBox(height: 4),
            Text(value, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
            sub,
          ],
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({required this.total});

  final String total;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.xs, boxShadow: AppShadows.hairline),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned(
            right: -16,
            bottom: -16,
            child: SvgIcon('confirm/watermark.svg', width: 73.333, height: 53.333),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VALOR TOTAL DEL\nSERVICIO',
                          style: AppText.sans(14, color: AppColors.darkMuted, lineHeight: 18, letterSpacing: 0.7)),
                      const SizedBox(height: 2),
                      Text.rich(TextSpan(children: [
                        TextSpan(
                            text: '$total ',
                            style: AppText.sans(28,
                                weight: FontWeight.w700, color: Colors.white, lineHeight: 36, letterSpacing: -0.56)),
                        TextSpan(text: 'COP', style: AppText.sans(16, color: AppColors.darkMuted, lineHeight: 20)),
                      ])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.onDarkFaint, borderRadius: AppRadius.xs),
                  child: Text('TARIFA\nESTÁNDAR',
                      textAlign: TextAlign.right,
                      style: AppText.sans(11, weight: FontWeight.w600, color: Colors.white, lineHeight: 16.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Medio de pago seleccionable (registro de control, no pasarela bancaria).
class PagoOpcionTile extends StatelessWidget {
  const PagoOpcionTile({
    super.key,
    required this.icon,
    required this.iconWidth,
    required this.iconHeight,
    required this.titulo,
    required this.detalle,
    required this.selected,
    this.sugerido = false,
    this.onTap,
  });

  final String icon;
  final double iconWidth;
  final double iconHeight;
  final String titulo;
  final String detalle;
  final bool selected;
  final bool sugerido;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: selected ? Colors.white : AppColors.surfaceLow,
        borderRadius: AppRadius.xs,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.surfaceHighest : AppColors.surfaceHigh,
              borderRadius: AppRadius.lg,
            ),
            child: selected ? const Dot(size: 10) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SvgIcon(icon, width: iconWidth, height: iconHeight),
                    const SizedBox(width: 8),
                    Expanded(child: Text(titulo, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24))),
                    if (sugerido)
                      Tag(
                        label: 'SUGERIDO',
                        background: AppColors.accentContainer,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        style: AppText.sans(11,
                            weight: FontWeight.w700, color: AppColors.onAccentContainer, lineHeight: 16.5, letterSpacing: 0.55),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(detalle, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
        ],
      ),
    );
    return GestureDetector(onTap: onTap, child: selected ? tile : Opacity(opacity: 0.9, child: tile));
  }
}
