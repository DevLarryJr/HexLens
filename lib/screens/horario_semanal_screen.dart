import 'package:flutter/material.dart';

import '../core/reloj.dart';
import '../data/mock_agenda.dart';
import '../data/mock_horario.dart';
import '../models/jornada.dart';
import '../services/remote/api_service.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/staff/horario_cards.dart';
import '../widgets/staff/jornada_dia_card.dart';
import '../widgets/staff/staff_tabs.dart';

export '../widgets/staff/staff_tabs.dart';

class HorarioSemanalScreen extends StatefulWidget {
  const HorarioSemanalScreen({super.key, this.onInasistencias, this.onConfigurarDia});

  final VoidCallback? onInasistencias;
  final VoidCallback? onConfigurarDia;

  @override
  State<HorarioSemanalScreen> createState() => _HorarioSemanalScreenState();
}

class _HorarioSemanalScreenState extends State<HorarioSemanalScreen> {
  int _semanaOffset = 0;

  DateTime get _lunes => Reloj.hoy.subtract(Duration(days: Reloj.hoy.weekday - 1)).add(Duration(days: 7 * _semanaOffset));

  static String _pausa(Jornada j) {
    final desde = j.almuerzoInicioMin ?? almuerzoInicioMin;
    final hasta = j.almuerzoFinMin ?? almuerzoInicioMin + Jornada.pausaAlmuerzoMin;
    return '${Jornada.hhmm(desde)} - ${Jornada.hhmm(hasta)} (${hasta - desde} min)';
  }

  void _refrescar() {
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    revisionJornada.addListener(_refrescar);
    _cargar();
  }

  @override
  void dispose() {
    revisionJornada.removeListener(_refrescar);
    super.dispose();
  }

  Future<void> _cargar() async {
    final f = fotografoJornada;
    if (f == null || horariosCargados(f)) return;
    try {
      await cargarHorarios(f);
    } on ApiException catch (e) {
      if (mounted) showHexToast(context, e.message);
    }
  }

  Future<void> _cambiarFotografo() async {
    final elegido = await elegirFotografoSheet(context, fotografosConJornada, fotografoJornada);
    if (elegido == null) return;
    elegirFotografoJornada(elegido);
    await _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final lunes = _lunes;
    final fotografo = fotografoJornada;
    final semana = semanaDe(fotografo, lunes);
    final numero = semanaIso(lunes);
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
        if (fotografo != null)
          StaffPerfilCard(
            nombre: fotografo.nombre,
            foto: 'foto_laura_staff.jpg',
            detalle: fotografo.equipo.isEmpty ? fotografo.especialidad : '${fotografo.especialidad} • ${fotografo.equipo}',
            fotografo: fotografo,
            onCambiar: _cambiarFotografo,
          )
        else
          const StaffPerfilCard(nombre: 'Laura Méndez', foto: 'foto_laura_staff.jpg', detalle: 'Retratos • Sony A7R V'),
        if (fotografo != null && !horariosCargados(fotografo)) ...[
          const SizedBox(height: 12),
          const LinearProgressIndicator(minHeight: 2),
        ],
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
            pausa: _pausa(j),
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
