import 'package:flutter/material.dart';

import '../../models/inasistencia.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../hex_form.dart';
import '../hex_widgets.dart';

class InasistenciaCard extends StatelessWidget {
  const InasistenciaCard({
    super.key,
    required this.inasistencia,
    this.citasAfectadas = 0,
    this.especialidad = '',
    this.onEditar,
    this.onLiberar,
  });

  final Inasistencia inasistencia;

  final int citasAfectadas;

  final String especialidad;
  final VoidCallback? onEditar;
  final VoidCallback? onLiberar;

  @override
  Widget build(BuildContext context) {
    return switch (inasistencia.tipo) {
      TipoInasistencia.capacitacion => _bloqueoActivo(),
      TipoInasistencia.citaMedica => _cumplida(),
      TipoInasistencia.licencia => _licencia(),
    };
  }

  String get _rango => '${fechaCorta(inasistencia.desde)} — ${fechaCorta(inasistencia.hasta)}';

  Widget _bloqueoActivo() {
    final i = inasistencia;
    final regular = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);
    final bold = AppText.sans(14, weight: FontWeight.w600, lineHeight: 18);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.sm,
        boxShadow: AppShadows.medium,
        border: const Border(top: BorderSide(color: AppColors.accentBright, width: 3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: SvgIcon('inasistencias/capacitacion.svg', width: 13.3, height: 10.7),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(i.categoria,
                    style: AppText.sans(14,
                        weight: FontWeight.w600, color: AppColors.accent, lineHeight: 18, letterSpacing: 0.7)),
              ),
              Tag(
                label: 'BLOQUEO ACTIVO',
                radius: 12,
                gap: 4,
                background: AppColors.accentContainer,
                leading: const SvgIcon('inasistencias/bloqueo_activo.svg', width: 10.5, height: 11.7),
                style: AppText.sans(13, weight: FontWeight.w700, color: AppColors.onAccentContainer, lineHeight: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(i.titulo, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
          const SizedBox(height: 12),
          InfoBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconoTexto(const SvgIcon('inasistencias/calendar.svg', width: 13.5, height: 15), _rango,
                    estilo: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24), separacion: 8),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const SizedBox(width: 26),
                    Expanded(
                      child: Text('${i.dias} ${i.dias == 1 ? 'día completo' : 'días completos'} (Jor. continua)',
                          style: regular),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      color: AppColors.surfaceHigh,
                      child: Text(i.horario.replaceFirst(' - ', ' -\n'), style: AppText.mono(12, lineHeight: 18)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          InfoBox(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SvgIcon('inasistencias/info.svg', width: 15, height: 17),
                const SizedBox(width: 8),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      style: regular,
                      children: [
                        TextSpan(
                            text: '$citasAfectadas ${citasAfectadas == 1 ? 'cita afectada' : 'citas afectadas'}. ',
                            style: bold),
                        const TextSpan(text: 'Agenda inhabilitada para reservas de '),
                        TextSpan(text: especialidad, style: bold),
                        const TextSpan(text: ' en las fechas seleccionadas.'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: HexButton(
                  label: 'Editar',
                  height: 44,
                  radius: 2,
                  shadow: null,
                  gap: 6,
                  onPressed: onEditar,
                  background: AppColors.surfaceHigh,
                  foreground: AppColors.onSurface,
                  leading: const SvgIcon('inasistencias/edit.svg', width: 12, height: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: HexButton(
                  label: 'Liberar Fechas',
                  height: 44,
                  radius: 2,
                  gap: 6,
                  background: Colors.white,
                  foreground: AppColors.accent,
                  onPressed: onLiberar,
                  leading: const SvgIcon('inasistencias/liberar.svg', width: 10.7, height: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cumplida() {
    final i = inasistencia;
    return HexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: SvgIcon('inasistencias/cita_medica.svg', width: 12.5, height: 12.5),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(i.categoria,
                    style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.7)),
              ),
              const _EstadoTag('CUMPLIDA', 'inasistencias/cumplida.svg'),
            ],
          ),
          Text(i.titulo, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 26)),
          const SizedBox(height: 12),
          InfoBox(
            child: Row(
              children: [
                const SvgIcon('inasistencias/calendar_small.svg', width: 13.5, height: 15),
                const SizedBox(width: 8),
                Text('${diaMes(i.desde)}\n${i.desde.year}',
                    style: AppText.sans(16, lineHeight: 20)),
                const SizedBox(width: 24),
                Expanded(child: Text(i.horario, style: AppText.mono(13, lineHeight: 18))),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const SvgIcon('inasistencias/attachment.svg', width: 13.3, height: 8.3),
              const SizedBox(width: 6),
              Text(i.adjunto ? 'Documento médico adjunto ' : 'Sin documento adjunto',
                  style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              if (i.adjunto) const Text('✓', style: TextStyle(color: AppColors.accentBright)),
              const Spacer(),
              const SvgIcon('inasistencias/ver.svg', width: 32.5, height: 33.3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _licencia() {
    final i = inasistencia;
    final muted = AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18);
    return HexCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(i.fotografo.replaceFirst(' ', '\n'),
                  style: AppText.sans(14, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 18)),
              const SizedBox(width: 12),
              const Padding(
                padding: EdgeInsets.only(top: 7),
                child: Dot(size: 4, color: AppColors.outlineVariant),
              ),
              const SizedBox(width: 6),
              Expanded(child: Text(i.area ?? '', style: muted)),
              const _EstadoTag('EN PAUSA', 'inasistencias/pausa.svg'),
            ],
          ),
          Text(i.titulo, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 26)),
          const SizedBox(height: 12),
          InfoBox(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(_rango, style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18))),
                    Text('${i.dias} ${i.dias == 1 ? 'DÍA' : 'DÍAS'}',
                        style: AppText.mono(11, weight: FontWeight.w700, color: AppColors.accent, lineHeight: 18)),
                  ],
                ),
                const SizedBox(height: 4),
                if (i.motivo != null) Text('Motivo: ${i.motivo}', style: muted),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoTag extends StatelessWidget {
  const _EstadoTag(this.label, this.icon);

  final String label;
  final String icon;

  @override
  Widget build(BuildContext context) {
    return Tag(
      label: label,
      radius: 12,
      gap: 4,
      background: AppColors.surfaceHigh,
      leading: SvgIcon(icon, width: 11.7, height: 11.7),
      style: AppText.sans(14, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 18, letterSpacing: 0.7),
    );
  }
}
