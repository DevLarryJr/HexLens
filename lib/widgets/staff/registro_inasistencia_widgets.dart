import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../hex_form.dart';
import '../hex_widgets.dart';

class PersonalAsignadoCard extends StatelessWidget {
  const PersonalAsignadoCard({
    super.key,
    required this.nombre,
    required this.foto,
    required this.staffId,
    required this.detalle,
    required this.operador,
  });

  final String nombre;

  final String foto;

  final String staffId;

  final String detalle;

  final String operador;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.sm,
                    child: Image.asset('assets/images/$foto', width: 60, height: 60, fit: BoxFit.cover),
                  ),
                  Positioned(
                    right: -6,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const SvgIcon('reg_inasistencia/camera.svg', width: 10, height: 9),
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
                        Expanded(child: Text(nombre, style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 24))),
                        Tag(label: staffId, background: AppColors.surfaceHigh, padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            style: AppText.mono(12, color: AppColors.onSurface)),
                      ],
                    ),
                    Text(detalle, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 20)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          InfoBox(
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
            child: Row(
              children: [
                Text('Cambiar\nfotógrafo:', style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    color: Colors.white,
                    child: Text(operador,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.sans(14, weight: FontWeight.w500, lineHeight: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PeriodoDesconexionCard extends StatelessWidget {
  const PeriodoDesconexionCard({
    super.key,
    required this.dias,
    required this.inicio,
    required this.valido,
    required this.jornadaCompleta,
    required this.onJornadaCompleta,
    this.fin,
    this.onInicio,
    this.onFin,
  });

  final int dias;

  final String inicio;
  final String? fin;
  final bool valido;
  final bool jornadaCompleta;
  final ValueChanged<bool> onJornadaCompleta;
  final VoidCallback? onInicio;
  final VoidCallback? onFin;

  @override
  Widget build(BuildContext context) {
    return HexCard(
      radius: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SvgIcon('reg_inasistencia/periodo.svg', width: 16.7, height: 17.5),
              const SizedBox(width: 10),
              Expanded(child: Text('Periodo de\nDesconexión', style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 26))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: AppColors.accentContainer,
                child: Text('$dias ${dias == 1 ? 'día' : 'días'}\ncalculados',
                    style: AppText.sans(12, color: AppColors.onAccentContainer, lineHeight: 16)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _fecha(fin == null ? 'Fecha' : 'Fecha Inicial', inicio, onInicio,
                  const SvgIcon('reg_inasistencia/fecha_inicio.svg', width: 15, height: 16.7)),
              if (fin != null) ...[
                const SizedBox(width: 20),
                _fecha('Fecha Final', fin!, onFin, const SvgIcon('reg_inasistencia/fecha_fin.svg', width: 15, height: 16.7)),
              ],
            ],
          ),
          const SizedBox(height: 12),
          InfoBox(
            icon: valido ? Icons.check_circle : Icons.error,
            iconColor: valido ? Colors.black : AppColors.accentBright,
            child: Text.rich(TextSpan(
              style: AppText.sans(14, lineHeight: 18),
              children: [
                TextSpan(text: 'Validación de fechas: ', style: AppText.sans(14, weight: FontWeight.w600, lineHeight: 18)),
                TextSpan(
                    text: valido
                        ? 'La fecha final es posterior a la fecha inicial.'
                        : 'La fecha final no puede ser anterior a la inicial.'),
              ],
            )),
          ),
          const SizedBox(height: 16),
          HexSwitchRow(
            title: 'Ausencia de jornada completa',
            subtitle: 'Inhabilita franjas de 08:00 a 19:00 hrs',
            value: jornadaCompleta,
            onChanged: onJornadaCompleta,
          ),
        ],
      ),
    );
  }

  Widget _fecha(String label, String valor, VoidCallback? onTap, Widget icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 20)),
          const SizedBox(height: 6),
          InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: AppColors.surfaceLow,
              child: Row(
                children: [
                  Expanded(child: Text(valor, style: AppText.sans(16, lineHeight: 22))),
                  icon,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuditoriaAgendaCard extends StatelessWidget {
  const AuditoriaAgendaCard({super.key, required this.rango, required this.citas, required this.fotografo});

  final String rango;

  final int citas;
  final String fotografo;

  @override
  Widget build(BuildContext context) {
    final libre = citas == 0;
    return HexCard(
      radius: 4,
      child: Column(
        children: [
          Row(
            children: [
              const SvgIcon('reg_inasistencia/auditoria.svg', width: 16.7, height: 16.6),
              const SizedBox(width: 8),
              Expanded(child: Text('Auditoría de\nAgenda', style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 26))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: libre ? AppColors.successContainer : AppColors.errorContainer,
                child: Row(
                  children: [
                    libre
                        ? const SvgIcon('reg_inasistencia/sin_conflictos.svg', width: 12.5, height: 12.5)
                        : const Icon(Icons.warning_amber, size: 14, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text(
                        libre
                            ? 'Sin conflictos\ndetectados'
                            : citas == 1
                                ? '1 conflicto\ndetectado'
                                : '$citas conflictos\ndetectados',
                        style: AppText.sans(14,
                            weight: FontWeight.w500, color: libre ? AppColors.successDark : AppColors.accent, lineHeight: 18)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InfoBox(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  color: AppColors.surfaceHigh,
                  child: const SvgIcon('reg_inasistencia/analisis.svg', width: 15, height: 16.7),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(TextSpan(
                        style: AppText.sans(16, lineHeight: 24),
                        children: [
                          const TextSpan(text: 'Análisis de reservas en el rango '),
                          TextSpan(text: rango, style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                          const TextSpan(text: ': '),
                          TextSpan(
                              text: '$citas ${citas == 1 ? 'cita' : 'citas'}',
                              style: AppText.sans(16, weight: FontWeight.w600, color: AppColors.accentBright, lineHeight: 24)),
                          TextSpan(
                              text: ' ${citas == 1 ? 'programada' : 'programadas'} para $fotografo',
                              style: AppText.sans(16, weight: FontWeight.w600, lineHeight: 24)),
                          const TextSpan(text: ' en estas fechas.'),
                        ],
                      )),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 22),
                            child: SvgIcon('reg_inasistencia/seguro.svg', width: 9.3, height: 11.7),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                                libre
                                    ? 'Es seguro bloquear el calendario y revocar la asignación de sesiones públicas.'
                                    : 'Reagenda o reasigna esas reservas antes de bloquear el calendario.',
                                style: AppText.sans(14, color: AppColors.onSurfaceVariant, lineHeight: 20)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
