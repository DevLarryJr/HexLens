import 'package:flutter/material.dart';

import '../data/mock_agenda.dart';
import '../core/reloj.dart';
import '../data/mock_horario.dart';
import '../models/jornada.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/staff/horario_cards.dart';
import '../widgets/staff/jornada_dia_card.dart';
import '../widgets/staff/staff_tabs.dart';

export '../widgets/staff/staff_tabs.dart';

/// Figma: "HexLens - Horario Semanal de Fotógrafo" (19:3644)
class HorarioSemanalScreen extends StatefulWidget {
  const HorarioSemanalScreen({super.key, this.onInasistencias, this.onConfigurarDia});

  final VoidCallback? onInasistencias;
  final VoidCallback? onConfigurarDia;

  @override
  State<HorarioSemanalScreen> createState() => _HorarioSemanalScreenState();
}

class _HorarioSemanalScreenState extends State<HorarioSemanalScreen> {
  int _semanaOffset = 0;

  /// Lunes de la semana visible: la de hoy más el desplazamiento.
  DateTime get _lunes => Reloj.hoy.subtract(Duration(days: Reloj.hoy.weekday - 1)).add(Duration(days: 7 * _semanaOffset));

  static final _pausa = '${Jornada.hhmm(almuerzoInicioMin)} - '
      '${Jornada.hhmm(almuerzoInicioMin + Jornada.pausaAlmuerzoMin)} (${Jornada.pausaAlmuerzoMin} min)';

  @override
  Widget build(BuildContext context) {
    final lunes = _lunes;
    final semana = semanaLaura(lunes);
    final numero = semanaIso(lunes);
    // La carga regular no cuenta la media jornada especial ni los días libres.
    final regulares = semana.where((j) => !j.libre && !j.especial).toList();
    final carga = regulares.fold(0, (t, j) => t + j.minutosEfectivos) ~/ 60;
    final sesionesHoy = programadasDeHoy().length;

    return HeaderScaffold(
      header: HexHeader(
        title: 'Horario Semanal',
      ),
      bottomPadding: 28,
      children: [
        const SizedBox(height: 16),
        StaffTabs(current: 0, onTap: (i) => i == 1 ? widget.onInasistencias?.call() : null),
        const SizedBox(height: 16),
        const StaffPerfilCard(nombre: 'Laura Méndez', foto: 'foto_laura_staff.jpg', detalle: 'Retratos • Sony A7R V'),
        const SizedBox(height: 16),
        HorarioMetricas(
          carga: '${carga}h',
          jornadas: '${regulares.length} ${regulares.length == 1 ? 'Día' : 'Días'}',
          pausa: '${Jornada.pausaAlmuerzoMin} min',
        ),
        const SizedBox(height: 20),
        SemanaNavegador(
          etiqueta: _semanaOffset == 0 ? 'SEMANA ACTUAL' : 'SEMANA ${_semanaOffset > 0 ? '+' : ''}$_semanaOffset',
          titulo: 'Sem $numero • ${nombreMes(lunes)} ${lunes.year}',
          onAnterior: () => setState(() => _semanaOffset--),
          onSiguiente: () => setState(() => _semanaOffset++),
        ),
        const SizedBox(height: 16),
        for (final j in semana) ...[
          JornadaDiaCard(
            jornada: j,
            hoy: mismoDia(j.fecha, Reloj.hoy),
            pausa: _pausa,
            sesionesHoy: sesionesHoy,
            onEditar: widget.onConfigurarDia,
          ),
          const SizedBox(height: 8),
        ],
        const SizedBox(height: 12),
        HexButton(
          label: '+ Agregar / Configurar Día',
          gap: 4,
          shadow: AppShadows.medium,
          onPressed: widget.onConfigurarDia,
          leading: const SvgIcon('horario/add_circle.svg', width: 16.667),
        ),
        const SizedBox(height: 8),
        HexButton(
          label: 'Replicar a la siguiente semana',
          gap: 4,
          shadow: null,
          background: AppColors.surfaceContainer,
          foreground: Colors.black,
          onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.black,
            content: Text('Horario replicado a la semana ${numero + 1}'),
          )),
          leading: const SvgIcon('horario/copy.svg', width: 14.167, height: 16.667),
        ),
        const SizedBox(height: 16),
        const _ReglaValidacion(),
      ],
    );
  }
}

class _ReglaValidacion extends StatelessWidget {
  const _ReglaValidacion();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surfaceHigh, borderRadius: AppRadius.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SvgIcon('horario/shield.svg', width: 13.333, height: 18.667),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Regla de agendamiento',
                    style: AppText.sans(13, weight: FontWeight.w700, color: Colors.black, lineHeight: 16.25)),
                const SizedBox(height: 4),
                Text(
                  'Las reservas fotográficas solo pueden agendarse dentro de la jornada activa del '
                  'fotógrafo y estrictamente fuera del intervalo de almuerzo o inasistencias '
                  'reportadas en sistema.',
                  style: AppText.sans(12, color: AppColors.onSurfaceVariant, lineHeight: 19.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
