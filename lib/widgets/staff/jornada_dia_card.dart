import 'package:flutter/material.dart';

import '../../models/jornada.dart';
import '../../theme/app_theme.dart';
import '../../utils/formato.dart';
import '../hex_widgets.dart';

class JornadaDiaCard extends StatelessWidget {
  const JornadaDiaCard({
    super.key,
    required this.jornada,
    required this.hoy,
    required this.pausa,
    this.sesionesHoy = 0,
    this.onEditar,
  });

  final Jornada jornada;
  final bool hoy;

  final String pausa;

  final int sesionesHoy;
  final VoidCallback? onEditar;

  @override
  Widget build(BuildContext context) {
    if (jornada.libre) return _libre();
    if (hoy) return _hoy();
    return _regular();
  }

  String get _nombre => nombreDia(jornada.fecha);

  Widget _libre() {
    return Opacity(
      opacity: 0.9,
      child: HexCard(
        color: AppColors.surfaceLow,
        child: Row(
          children: [
            _DiaBadge(jornada: jornada, hoy: false),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(_nombre,
                          style: AppText.sans(16, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 24)),
                      const SizedBox(width: 4),
                      Tag(
                        label: 'Día Libre',
                        background: AppColors.surfaceHighest,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        style: AppText.sans(11, weight: FontWeight.w600, color: AppColors.onSurfaceVariant, lineHeight: 24),
                      ),
                    ],
                  ),
                  Text('Descanso semanal programado',
                      style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                ],
              ),
            ),
            Material(
              color: Colors.white,
              borderRadius: AppRadius.sm,
              elevation: 0.5,
              child: InkWell(
                onTap: onEditar,
                borderRadius: AppRadius.sm,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: [
                      const SvgIcon('horario/plus_red.svg', width: 9.333),
                      const SizedBox(width: 6),
                      Text('Añadir\nturno',
                          textAlign: TextAlign.center,
                          style: AppText.sans(12, weight: FontWeight.w600, color: AppColors.accent, lineHeight: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hoy() {
    return HexCard(
      accentBar: true,
      shadow: const [
        BoxShadow(color: AppColors.accentTint, offset: Offset(0, 4), blurRadius: 6, spreadRadius: -1),
        BoxShadow(color: AppColors.accentTint, offset: Offset(0, 2), blurRadius: 4, spreadRadius: -2),
      ],
      child: Column(
        children: [
          Row(
            children: [
              _DiaBadge(jornada: jornada, hoy: true),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_nombre, style: AppText.sans(16, weight: FontWeight.w700, color: Colors.black, lineHeight: 24)),
                        const SizedBox(width: 4),
                        Tag(
                          label: 'HOY',
                          radius: 12,
                          background: AppColors.accentContainer,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          style: AppText.sans(11,
                              weight: FontWeight.w700, color: AppColors.onAccentContainer, lineHeight: 24, letterSpacing: 0.55),
                        ),
                      ],
                    ),
                    IconoTexto(const SvgIcon('horario/clock_dark.svg', width: 12.5),
                        '${jornada.horario} (${jornada.horas} efectivas)',
                        estilo: AppText.sans(14, weight: FontWeight.w500, color: Colors.black, lineHeight: 18),
                        separacion: 4),
                  ],
                ),
              ),
              _EditarButton(onTap: onEditar),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            decoration: BoxDecoration(color: AppColors.accentBright, borderRadius: AppRadius.sm),
            child: Row(
              children: [
                const SvgIcon('horario/camera.svg', width: 15, height: 13.5),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                      'Hoy en estudio: $sesionesHoy ${sesionesHoy == 1 ? 'sesión agendada' : 'sesiones agendadas'}',
                      style: AppText.sans(13, weight: FontWeight.w700, color: AppColors.onAccentBright, lineHeight: 24)),
                ),
                const SvgIcon('horario/add_white.svg', width: 14.667),
              ],
            ),
          ),
          const SizedBox(height: 4),
          _Almuerzo(pausa: pausa, top: 4),
        ],
      ),
    );
  }

  Widget _regular() {
    final especial = jornada.especial;
    return HexCard(
      child: Column(
        children: [
          Row(
            children: [
              _DiaBadge(jornada: jornada, hoy: false),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(_nombre, style: AppText.sans(16, weight: FontWeight.w600, color: Colors.black, lineHeight: 24)),
                        if (especial)
                          Tag(
                            label: jornada.horas,
                            background: AppColors.neutralContainer,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            style: AppText.sans(11, weight: FontWeight.w500, color: AppColors.onNeutralContainer, lineHeight: 24),
                          )
                        else
                          Text('• ${jornada.horas} efectivas',
                              style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                      ],
                    ),
                    IconoTexto(const SvgIcon('horario/clock.svg', width: 12.5), jornada.horario,
                        estilo: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18), separacion: 4),
                  ],
                ),
              ),
              especial
                  ? Container(
                      width: 106,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.lg),
                      child: Text('Media jornada especial',
                          style: AppText.sans(12, weight: FontWeight.w500, color: Colors.black, lineHeight: 16)),
                    )
                  : Tag(
                      label: 'Activa',
                      background: AppColors.surfaceHigh,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      style: AppText.sans(12, weight: FontWeight.w600, color: Colors.black, lineHeight: 20),
                    ),
              const SizedBox(width: 4),
              _EditarButton(onTap: onEditar),
            ],
          ),
          const SizedBox(height: 8),
          jornada.almuerzo
              ? _Almuerzo(pausa: pausa)
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.xs),
                  child: IconoTexto(const SvgIcon('horario/info.svg', width: 11.667),
                      'Sin pausa de almuerzo programada para este bloque corto.',
                      estilo: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 20, style: FontStyle.italic),
                      ajuste: FlexFit.tight),
                ),
        ],
      ),
    );
  }
}

class _DiaBadge extends StatelessWidget {
  const _DiaBadge({required this.jornada, required this.hoy});

  final Jornada jornada;
  final bool hoy;

  @override
  Widget build(BuildContext context) {
    final libre = jornada.libre;
    final color = hoy ? Colors.white : (libre ? AppColors.onSurfaceVariant : Colors.black);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: hoy ? AppColors.accent : (libre ? AppColors.surfaceHigh : AppColors.surfaceContainer),
        borderRadius: AppRadius.sm,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(diaCorto(jornada.fecha),
              style: AppText.sans(10, weight: FontWeight.w700, color: color, lineHeight: 14, letterSpacing: 0.25)),
          Text('${jornada.fecha.day}',
              style: AppText.sans(16, weight: hoy ? FontWeight.w600 : FontWeight.w700, color: color, lineHeight: 16)),
        ],
      ),
    );
  }
}

class _EditarButton extends StatelessWidget {
  const _EditarButton({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.sm,
      child: const SizedBox(width: 36, height: 36, child: Center(child: SvgIcon('horario/edit.svg', width: 13.5))),
    );
  }
}

class _Almuerzo extends StatelessWidget {
  const _Almuerzo({required this.pausa, this.top = 8});

  final String pausa;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(8, top, 8, 6),
      decoration: BoxDecoration(color: AppColors.surfaceLow, borderRadius: AppRadius.sm),
      child: Row(
        children: [
          const SvgIcon('horario/lunch.svg', width: 10, height: 13.333),
          const SizedBox(width: 6),
          Expanded(
            child: Text('Pausa Almuerzo Técnico:', style: AppText.sans(13, color: AppColors.onSurfaceVariant, lineHeight: 24)),
          ),
          Text(pausa, style: AppText.sans(13, weight: FontWeight.w500, color: AppColors.onSurfaceVariant, lineHeight: 24)),
        ],
      ),
    );
  }
}
