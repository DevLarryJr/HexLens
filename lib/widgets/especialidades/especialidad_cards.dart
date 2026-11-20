import 'package:flutter/material.dart';

import '../../models/especialidad.dart';
import '../../theme/app_theme.dart';
import '../hex_widgets.dart';

class SincronizacionBanner extends StatelessWidget {
  const SincronizacionBanner({super.key, required this.mensaje, this.onCerrar});

  final String mensaje;
  final VoidCallback? onCerrar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: AppRadius.md,
        boxShadow: AppShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: AppColors.accent, borderRadius: AppRadius.xs),
            child: const SvgIcon('especialidades/check.svg', width: 13.333),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sincronización técnica exitosa', style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18)),
                Text(mensaje,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              ],
            ),
          ),
          InkWell(
            onTap: onCerrar,
            child: const SizedBox(
              width: 28,
              height: 32,
              child: Center(child: SvgIcon('especialidades/close.svg', width: 10.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class EspecialidadesTitulo extends StatelessWidget {
  const EspecialidadesTitulo({super.key, this.onNueva});

  final VoidCallback? onNueva;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconoTexto(const SvgIcon('especialidades/sparkle.svg', width: 12), 'MÓDULO OPERATIVO HEXLENS',
                  estilo: AppText.sans(14,
                            weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18, letterSpacing: 0.7), separacion: 4, ajuste: FlexFit.loose),
              Text('Catálogo de Especialidades',
                  style: AppText.sans(20, weight: FontWeight.w600, lineHeight: 28, letterSpacing: -0.2)),
            ],
          ),
        ),
        SizedBox(
          width: 92,
          child: HexButton(
            label: 'Nueva',
            height: 44,
            radius: 2,
            gap: 4,
            onPressed: onNueva,
            leading: const SvgIcon('especialidades/plus.svg', width: 11.667),
          ),
        ),
      ],
    );
  }
}

class _IconoEspecialidad extends StatelessWidget {
  const _IconoEspecialidad(this.e);

  final Especialidad e;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.xs),
      child: SvgIcon(e.icono.svg, width: e.icono.ancho, height: e.icono.alto),
    );
  }
}

class EspecialidadCard extends StatelessWidget {
  const EspecialidadCard({
    super.key,
    required this.especialidad,
    required this.servicios,
    required this.titular,
    required this.iniciales,
    this.destacada = false,
    this.onEditar,
    this.onEliminar,
  });

  final Especialidad especialidad;

  final List<String> servicios;

  final String titular;
  final String iniciales;

  final bool destacada;
  final VoidCallback? onEditar;
  final VoidCallback? onEliminar;

  @override
  Widget build(BuildContext context) {
    final e = especialidad;
    final n = servicios.length;
    return HexCard(
      shadow: AppShadows.hairline,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _IconoEspecialidad(e),
                  if (destacada) const Positioned(right: -4, top: -4, child: Dot(size: 10)),
                ],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(e.nombre, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                        if (destacada) ...[
                          const SizedBox(width: 6),
                          const SvgIcon('especialidades/sparkle.svg', width: 12),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        const SvgIcon('especialidades/servicios.svg', width: 11.667, height: 12.25),
                        const SizedBox(width: 4),
                        Text('$n ${n == 1 ? 'servicio asociado' : 'servicios asociados'}',
                            style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in servicios) Tag(label: s, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.xs),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.surfaceHighest, borderRadius: AppRadius.lg),
                  child: Text(iniciales, style: AppText.sans(12, weight: FontWeight.w600, lineHeight: 16)),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.rol, style: AppText.sans(11, color: AppColors.onSurfaceVariant, lineHeight: 13.75)),
                      Text(titular, style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18)),
                    ],
                  ),
                ),
                _TextoBoton('Editar', AppColors.onSurface, onEditar),
                const SizedBox(width: 4),
                _TextoBoton('Eliminar', AppColors.accent, onEliminar),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TextoBoton extends StatelessWidget {
  const _TextoBoton(this.label, this.color, this.onTap);

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: AppRadius.xs,
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        alignment: Alignment.center,
        child: Text(label, style: AppText.sans(14, weight: FontWeight.w500, color: color, lineHeight: 18)),
      ),
    );
  }
}

