import 'package:flutter/material.dart';

import '../../models/fotografo.dart';
import '../../theme/app_theme.dart';
import '../hex_widgets.dart';
import 'foto_fotografo.dart';

class FotografoCard extends StatelessWidget {
  const FotografoCard({
    super.key,
    required this.fotografo,
    required this.estado,
    this.onJornada,
    this.onInasistencia,
    this.onHorarios,
    this.onComisiones,
    this.onEditarFicha,
    this.onReactivar,
    this.motivoInactivo = 'LICENCIA TEMPORAL',
  });

  final Fotografo fotografo;

  final EstadoFotografo estado;
  final VoidCallback? onJornada;
  final VoidCallback? onInasistencia;
  final VoidCallback? onHorarios;
  final VoidCallback? onComisiones;
  final VoidCallback? onEditarFicha;
  final VoidCallback? onReactivar;

  final String motivoInactivo;

  @override
  Widget build(BuildContext context) {
    final f = fotografo;
    final inactivo = estado == EstadoFotografo.inactivo;
    final foto = FotoFotografo(f);

    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: inactivo ? AppColors.surfaceLow : Colors.white,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.hairline,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.md,
                          child: Container(
                            color: inactivo ? AppColors.surfaceDim : Colors.black,
                            width: 64,
                            height: 64,
                            child: inactivo ? ColorFiltered(colorFilter: AppFilters.grayscale, child: foto) : foto,
                          ),
                        ),
                        Positioned(
                          right: inactivo ? -4 : -9,
                          bottom: inactivo ? -4 : -13,
                          child: inactivo
                              ? const SvgIcon('fotografos/badge_inactive.svg', width: 20)
                              : const SvgIcon('fotografos/hex_badge.svg', width: 30),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: inactivo ? 48 : 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(f.nombre,
                                      style: AppText.sans(16,
                                          weight: FontWeight.w700,
                                          lineHeight: 24,
                                          decoration: inactivo ? TextDecoration.lineThrough : null)),
                                ),
                                if (!inactivo && f.score != null)
                                  Tag(
                                    label: f.score!.toStringAsFixed(1),
                                    radius: 12,
                                    gap: 4,
                                    background: AppColors.surfaceHigh,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    style: AppText.sans(12, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 18),
                                    trailing: const SvgIcon('fotografos/star.svg', width: 10.523, height: 10.031),
                                  ),
                              ],
                            ),
                            Text(f.documento, style: AppText.mono(12, lineHeight: 18)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                Tag(
                                  label: f.especialidad.toUpperCase(),
                                  background: AppColors.surfaceHigh,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  style: AppText.sans(11,
                                      weight: FontWeight.w600,
                                      color: inactivo ? AppColors.onSurfaceVariant : AppColors.onSurface,
                                      lineHeight: 16.5,
                                      letterSpacing: 0.55),
                                ),
                                EstadoFotografoBadge(estado: estado),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _Detalle(fotografo: f, inactivo: inactivo),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: _acciones(estado)),
              ],
            ),
          ),
          if (estado == EstadoFotografo.enTurno)
            Positioned(
              right: -12,
              top: -12,
              child: Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.accentWash, borderRadius: AppRadius.lg),
                child: const SvgIcon('fotografos/star_accent.svg', width: 18.333),
              ),
            ),
          if (inactivo)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceDim,
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4)),
                ),
                child: Text(motivoInactivo,
                    style: AppText.sans(10,
                        weight: FontWeight.w700, color: AppColors.onSurfaceVariant, lineHeight: 15, letterSpacing: 0.5)),
              ),
            ),
        ],
      ),
    );

    return inactivo ? Opacity(opacity: 0.85, child: card) : card;
  }

  List<Widget> _acciones(EstadoFotografo e) {
    return switch (e) {
      EstadoFotografo.enTurno => [
          _AccionRapida('Jornada', const SvgIcon('fotografos/jornada.svg', width: 15, height: 15.75),
              vertical: true, onTap: onJornada),
          const SizedBox(width: 4),
          _AccionRapida('Inasistencia', const SvgIcon('fotografos/inasistencia.svg', width: 13.5, height: 15),
              vertical: true, onTap: onInasistencia),
          const SizedBox(width: 4),
          _AccionRapida('Editar Ficha', const SvgIcon('fotografos/edit.svg', width: 15, height: 15.019),
              dark: true, vertical: true, onTap: onEditarFicha),
        ],
      EstadoFotografo.disponible || EstadoFotografo.fueraDeTurno => [
          _AccionRapida('Horarios', const SvgIcon('fotografos/clock.svg', width: 15), onTap: onHorarios),
          const SizedBox(width: 8),
          _AccionRapida('Ver Ficha', const SvgIcon('fotografos/ficha.svg', width: 15), dark: true, onTap: onEditarFicha),
        ],
      EstadoFotografo.almuerzo => [
          _AccionRapida('Horarios', const SvgIcon('fotografos/calendar.svg', width: 13.5, height: 15), onTap: onHorarios),
          const SizedBox(width: 8),
          _AccionRapida('Ficha Técnica', const SvgIcon('fotografos/ficha_tecnica.svg', width: 13.5, height: 12),
              dark: true, onTap: onEditarFicha),
        ],
      EstadoFotografo.inactivo => [
          _AccionRapida('Comisiones', const SvgIcon('fotografos/comisiones.svg', width: 13.5, height: 15),
              background: AppColors.surfaceHigh, onTap: onComisiones),
          const SizedBox(width: 8),
          _AccionRapida('Reactivar', const SvgIcon('fotografos/reactivar.svg', width: 12, height: 13.837),
              dark: true, background: AppColors.accent, onTap: onReactivar),
        ],
    };
  }
}

class EstadoFotografoBadge extends StatelessWidget {
  const EstadoFotografoBadge({super.key, required this.estado});

  final EstadoFotografo estado;

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.symmetric(horizontal: 8, vertical: 2);
    return switch (estado) {
      EstadoFotografo.enTurno => Tag(
          label: 'En turno',
          leading: const Dot(),
          gap: 4,
          background: AppColors.accentContainer,
          padding: padding,
          style: AppText.sans(11, weight: FontWeight.w500, color: AppColors.onAccentContainer, lineHeight: 16.5),
        ),
      EstadoFotografo.disponible => Tag(
          label: 'Disponible',
          leading: const Dot(color: AppColors.outline),
          gap: 4,
          padding: padding,
          style: AppText.sans(11, weight: FontWeight.w500, lineHeight: 16.5),
        ),
      EstadoFotografo.almuerzo => Tag(
          label: 'Pausa Almuerzo',
          leading: const SvgIcon('fotografos/lunch.svg', width: 10, height: 9),
          background: AppColors.surfaceHighest,
          padding: padding,
          style: AppText.sans(11, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 16.5),
        ),
      EstadoFotografo.inactivo => Tag(
          label: 'Inactivo',
          background: AppColors.errorContainer,
          padding: padding,
          style: AppText.sans(11, weight: FontWeight.w600, color: AppColors.onErrorContainer, lineHeight: 16.5),
        ),
      EstadoFotografo.fueraDeTurno => Tag(
          label: 'Fuera de turno',
          leading: const Dot(color: AppColors.outline),
          gap: 4,
          background: AppColors.surfaceHigh,
          padding: padding,
          style: AppText.sans(11, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 16.5),
        ),
    };
  }
}

class _Detalle extends StatelessWidget {
  const _Detalle({required this.fotografo, required this.inactivo});

  final Fotografo fotografo;
  final bool inactivo;

  @override
  Widget build(BuildContext context) {
    final etiqueta =
        AppText.sans(10, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 15, letterSpacing: 0.5);
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: inactivo ? AppColors.surfaceContainer : AppColors.surfaceLow,
        borderRadius: AppRadius.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(inactivo ? 'PACTADA' : 'COMISIÓN', style: etiqueta),
                  Text('${fotografo.comisionPct}%',
                      style: AppText.sans(20,
                          weight: FontWeight.w700,
                          color: inactivo ? AppColors.onSurfaceVariant : AppColors.accent,
                          lineHeight: 25,
                          letterSpacing: -0.2)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 3, 4, 3.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      inactivo
                          ? const SvgIcon('fotografos/history.svg', width: 9)
                          : const SvgIcon('fotografos/camera.svg', width: 10, height: 9),
                      const SizedBox(width: 4),
                      Text(inactivo ? 'REGISTRO HISTÓRICO' : 'EQUIPO ASIGNADO', style: etiqueta),
                    ],
                  ),
                  Text(fotografo.equipo.isEmpty ? 'Sin equipo registrado' : fotografo.equipo,
                      style: AppText.sans(14,
                          weight: FontWeight.w500,
                          color: inactivo ? AppColors.onSurfaceVariant : AppColors.onSurface,
                          lineHeight: 18)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccionRapida extends StatelessWidget {
  const _AccionRapida(this.label, this.icon, {this.dark = false, this.vertical = false, this.background, this.onTap});

  final String label;
  final Widget icon;
  final bool dark;
  final bool vertical;
  final Color? background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Colors.white : AppColors.onSurface;
    return Expanded(
      child: Material(
        color: background ?? (dark ? Colors.black : AppColors.surfaceContainer),
        borderRadius: AppRadius.sm,
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: AppRadius.sm,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: vertical ? 8 : 10),
            child: vertical
                ? Column(
                    children: [
                      icon,
                      const SizedBox(height: 2),
                      Text(label,
                          style: AppText.sans(11,
                              weight: dark ? FontWeight.w600 : FontWeight.w500, color: fg, lineHeight: 13.75)),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon,
                      const SizedBox(width: 6),
                      Text(label, style: AppText.sans(14, weight: FontWeight.w600, color: fg, lineHeight: 18)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
