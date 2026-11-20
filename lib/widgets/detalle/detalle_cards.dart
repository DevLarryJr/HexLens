import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class DetalleCodigo extends StatelessWidget {
  const DetalleCodigo({super.key, required this.codigo});

  final String codigo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Tag(
        label: codigo,
        background: AppColors.surfaceHigh,
        radius: 12,
        gap: 4,
        leading: const SvgIcon('detalle/hash.svg', width: 12.833),
      ),
    );
  }
}

class DetalleHeroCard extends StatelessWidget {
  const DetalleHeroCard({
    super.key,
    required this.cliente,
    required this.documento,
    required this.set,
    this.estado = 'Programada',
  });

  final String estado;

  final String cliente;

  final String documento;

  final String set;

  @override
  Widget build(BuildContext context) {
    final muted = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);
    return HexCard(
      shadow: AppShadows.hairline,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SESIÓN INDIVIDUAL',
                        style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.7)),
                    const SizedBox(height: 4),
                    Text(cliente,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(28, weight: FontWeight.w700, lineHeight: 36, letterSpacing: -0.56)),
                    Text(documento, style: muted),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLow,
                  borderRadius: AppRadius.lg,
                  boxShadow: AppShadows.soft,
                ),
                child: Row(
                  children: [
                    const Dot(size: 8, color: AppColors.accentBright),
                    const SizedBox(width: 6),
                    const SvgIcon('detalle/clock.svg', width: 13.333),
                    const SizedBox(width: 6),
                    Text(estado, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 20)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: IconoTexto(const SvgIcon('detalle/aperture.svg', width: 15), set,
                      estilo: AppText.sans(14, lineHeight: 18), separacion: 8, ajuste: FlexFit.loose),
                ),
                const SizedBox(width: 8),
                Text('Estilo Y2K', style: muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MoodboardRow extends StatelessWidget {
  const MoodboardRow({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _MoodTile('assets/images/moodboard.jpg', 'Referencia de estilo'),
        SizedBox(width: 8),
        _MoodTile('assets/images/setup_iluminacion.jpg', 'Esquema de luz'),
      ],
    );
  }
}

class _MoodTile extends StatelessWidget {
  const _MoodTile(this.asset, this.label);

  final String asset;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 112,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: AppRadius.md,
          boxShadow: AppShadows.hairline,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(asset, fit: BoxFit.cover),
            Positioned(
              left: 8,
              bottom: 6,
              child: ClipRRect(
                borderRadius: AppRadius.xs,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                  child: Container(
                    color: AppColors.scrimSoft,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    child: Text(label, style: AppText.sans(11, color: Colors.white, lineHeight: 16.5)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AgendaDetalleCard extends StatelessWidget {
  const AgendaDetalleCard({
    super.key,
    required this.creada,
    required this.fecha,
    required this.anio,
    required this.horario,
    required this.duracion,
    required this.telefono,
    required this.email,
  });

  final String creada;

  final String fecha;
  final int anio;

  final String horario;

  final String duracion;
  final String telefono;
  final String email;

  @override
  Widget build(BuildContext context) {
    final muted = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);
    return HexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconoTexto(const SvgIcon('detalle/calendar.svg', width: 13.5, height: 15), 'Agenda y\nTemporalidad',
                  estilo: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24), separacion: 8),
              Text(creada, style: muted),
            ],
          ),
          const SizedBox(height: 20),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DateBox(
                  'Fecha de Sesión',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fecha, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 20)),
                      Text('Año $anio', style: muted),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _DateBox(
                  'Bloque Horario',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(horario, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 20)),
                      const SizedBox(height: 1.5),
                      IconoTexto(const SvgIcon('detalle/timer.svg', width: 11.667), duracion,
                          estilo: AppText.sans(14, weight: FontWeight.w600, color: AppColors.accentBright, lineHeight: 18),
                          separacion: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Canales de Contacto Directo', style: muted),
          const SizedBox(height: 8),
          _ContactRow('detalle/phone.svg', 13.5, 13.5, telefono, 'Llamar'),
          const SizedBox(height: 8),
          _ContactRow('detalle/mail.svg', 15, 12, email, 'Enviar'),
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox(this.label, this.content);

  final String label;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
            const SizedBox(height: 4),
            content,
          ],
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow(this.icon, this.iconW, this.iconH, this.value, this.action);

  final String icon;
  final double iconW;
  final double iconH;
  final String value;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceLow,
      borderRadius: AppRadius.sm,
      child: InkWell(
        borderRadius: AppRadius.sm,
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              SvgIcon(icon, width: iconW, height: iconH),
              const SizedBox(width: 8),
              Expanded(
                child: Text(value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(16, weight: FontWeight.w500, lineHeight: 20)),
              ),
              Text(action, style: AppText.sans(14, color: AppColors.accent, lineHeight: 18)),
              const SvgIcon('detalle/chevron_right.svg', width: 4.317, height: 7),
            ],
          ),
        ),
      ),
    );
  }
}

class ServicioLiquidacionCard extends StatelessWidget {
  const ServicioLiquidacionCard({
    super.key,
    required this.especialidad,
    required this.servicio,
    required this.descripcion,
    required this.tarifa,
    required this.fotografoIniciales,
    required this.fotografo,
    required this.comisionPct,
    required this.liquidacion,
    required this.pago,
  });

  final String especialidad;
  final String servicio;
  final String descripcion;

  final String tarifa;
  final String fotografoIniciales;
  final String fotografo;
  final int comisionPct;

  final String liquidacion;
  final String pago;

  @override
  Widget build(BuildContext context) {
    final muted = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);
    return HexCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconoTexto(const SvgIcon('detalle/service.svg', width: 16.5, height: 12), 'Servicio y\nLiquidación',
                  estilo: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24), separacion: 8),
              Container(
                width: 104,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppColors.surfaceContainer, borderRadius: AppRadius.xs),
                child: Text('Especialidad:\n$especialidad', style: AppText.sans(14, lineHeight: 18)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(servicio, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                    Text(descripcion, style: muted),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const SizedBox(height: 3.5),
                  Text('Tarifa Total', style: muted),
                  Text(tarifa, style: AppText.sans(28, weight: FontWeight.w700, lineHeight: 35, letterSpacing: -0.84)),
                  Text('COP', style: muted),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: Colors.black, borderRadius: AppRadius.lg),
                          child: Text(fotografoIniciales,
                              style: AppText.sans(12, weight: FontWeight.w700, color: Colors.white, lineHeight: 16)),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fotografo, style: AppText.sans(16, weight: FontWeight.w500, lineHeight: 20)),
                            Text('Fotógrafa de planta\nasignada', style: muted),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 92,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.xs),
                      child: Text('Comisión\n$comisionPct%', style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Liquidación proyectada:', style: muted),
                    Text(liquidacion, style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconoTexto(const SvgIcon('detalle/bank.svg', width: 15), pago,
                  estilo: AppText.sans(16, weight: FontWeight.w500, lineHeight: 20), separacion: 8),
              Tag(
                label: 'Registrado',
                gap: 4,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18),
                leading: const SvgIcon('detalle/verified.svg', width: 12.833, height: 12.25),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
