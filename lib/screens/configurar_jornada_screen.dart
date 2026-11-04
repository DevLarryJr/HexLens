import 'package:flutter/material.dart';

import '../data/mock_agenda.dart';
import '../core/reloj.dart';
import '../data/mock_fotografos.dart';
import '../data/mock_horario.dart';
import '../models/jornada.dart';
import '../models/sesion.dart';
import '../theme/app_theme.dart';
import '../utils/formato.dart';
import '../widgets/calendario_mensual.dart';
import '../widgets/hex_form.dart';
import '../widgets/hex_widgets.dart';
import '../widgets/jornada/jornada_cards.dart';

/// Figma: "HexLens - Configurar Jornada y Almuerzo" (19:4377)
class ConfigurarJornadaScreen extends StatefulWidget {
  const ConfigurarJornadaScreen({super.key});

  @override
  State<ConfigurarJornadaScreen> createState() => _ConfigurarJornadaScreenState();
}

/// Jornada editable de un día (minutos desde la medianoche).
class _Edicion {
  _Edicion.desde(Jornada j)
      : inicio = j.inicioMin ?? 8 * 60,
        fin = j.finMin ?? 17 * 60,
        almuerzo = j.libre || j.almuerzo;

  _Edicion.copia(_Edicion o)
      : inicio = o.inicio,
        fin = o.fin,
        almuerzo = o.almuerzo,
        almInicio = o.almInicio,
        almFin = o.almFin;

  int inicio;
  int fin;
  bool almuerzo;
  int almInicio = almuerzoInicioMin;
  int almFin = almuerzoInicioMin + Jornada.pausaAlmuerzoMin;

  bool get turnoValido => inicio < fin;
  bool get almuerzoValido => !almuerzo || (almInicio < almFin && almInicio >= inicio && almFin <= fin);
  int get neto => (fin - inicio) - (almuerzo ? (almFin - almInicio) : 0);

  /// La sesión (inicio/fin en minutos) queda fuera del turno o cruza el almuerzo.
  bool choca(int desde, int hasta) =>
      desde < inicio || hasta > fin || (almuerzo && desde < almFin && hasta > almInicio);
}

class _ConfigurarJornadaScreenState extends State<ConfigurarJornadaScreen> with ProtegeCambios {
  /// Horas de cada día de la semana (el día que se mira y "aplicar L–V" no cuentan como cambios).
  @override
  String get firmaFormulario =>
      [for (final e in _ediciones) '${e.inicio}-${e.fin}-${e.almuerzo}-${e.almInicio}-${e.almFin}'].join('|');

  static const _fotografo = 'Laura Méndez';
  /// Hasta cuántas semanas hacia adelante se puede programar.
  static const _semanasAdelante = 8;

  /// Semanas desde la actual (0 = esta semana).
  int _semanaOffset = 0;

  DateTime get _lunes =>
      DateTime(Reloj.hoy.year, Reloj.hoy.month, Reloj.hoy.day - (Reloj.hoy.weekday - 1) + 7 * _semanaOffset);
  late List<Jornada> _semana = semanaLaura(_lunes);
  late List<_Edicion> _ediciones = [for (final j in _semana) _Edicion.desde(j)];

  /// Cambia a la semana [paso] semanas antes o después y carga su jornada (lo no guardado se descarta).
  void _cambiarSemana(int paso) {
    setState(() {
      _semanaOffset += paso;
      _semana = semanaLaura(_lunes);
      _ediciones = [for (final j in _semana) _Edicion.desde(j)];
      _dia = _semanaOffset == 0 ? Reloj.hoy.weekday - 1 : 0;
    });
    // La semana recién cargada es el nuevo punto de partida: salir sin tocarla no pregunta.
    reiniciarFirma();
  }
  int _dia = Reloj.hoy.weekday - 1;
  bool _aplicarTodos = true;

  _Edicion get _e => _ediciones[_dia];
  String get _nombre => nombreDia(_semana[_dia].fecha);

  /// Jornada que regirá [dia] al guardar (con "aplicar L–V", la del día editado).
  _Edicion _vigente(int dia) => _aplicarTodos && _dia < 5 && dia < 5 ? _e : _ediciones[dia];

  String get _estadoAgenda {
    final programadas = sesionesAgenda.where((s) =>
        s.fotografo == _fotografo &&
        s.estado == SesionEstado.programada &&
        !s.inicio.isBefore(_lunes) &&
        s.inicio.isBefore(_lunes.add(const Duration(days: 7))));
    final conflictos = programadas.where((s) {
      final desde = s.inicio.hour * 60 + s.inicio.minute;
      return _vigente(s.inicio.weekday - 1).choca(desde, desde + s.duracionMin);
    }).length;
    final n = programadas.length;
    return '$conflictos ${conflictos == 1 ? 'conflicto' : 'conflictos'} con '
        '${n == 1 ? '1 reserva programada' : '$n reservas programadas'} de esta semana.';
  }

  Future<void> _pick(int actual, ValueChanged<int> set) async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: actual ~/ 60, minute: actual % 60),
    );
    if (t != null) setState(() => set(t.hour * 60 + t.minute));
  }

  Widget _hora(String label, int value, Widget icon, ValueChanged<int> set) {
    void ajustar(int delta) => setState(() => set((value + delta).clamp(0, 23 * 60 + 30)));
    return HoraStepperBox(
      label: label,
      hora: horaAmPm(DateTime(2000, 1, 1, value ~/ 60, value % 60)),
      icon: icon,
      onTap: () => _pick(value, set),
      onSubir: () => ajustar(30),
      onBajar: () => ajustar(-30),
    );
  }

  void _guardar() {
    if (_aplicarTodos && _dia < 5) {
      for (var i = 0; i < 5; i++) {
        if (i != _dia) _ediciones[i] = _Edicion.copia(_e);
      }
    }
    showHexToast(context, 'Jornada ${_aplicarTodos ? 'lunes a viernes' : _nombre.toLowerCase()} guardada');
    salirSinPreguntar();
  }

  @override
  Widget build(BuildContext context) {
    final e = _e;
    final valido = e.turnoValido && e.almuerzoValido;
    final horas = (e.fin - e.inicio) / 60;
    final total = (e.fin - e.inicio).clamp(1, 24 * 60);
    final fotografo = fotografoPorNombre(_fotografo);

    return protegerSalida(HeaderScaffold(
      header: HexHeader(title: 'Jornada Laboral', cerrar: true),
      bottomPadding: 28,
      children: [
        const SizedBox(height: 20),
        FichaJornadaCard(
          nombre: _fotografo,
          foto: fotografo?.foto ?? 'foto_sara_mendez.jpg',
          detalle: 'Fotógrafa Principal • ID #HL-084',
          dia: _nombre.toUpperCase(),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const SvgIcon('jornada/calendar.svg', width: 13.5, height: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Día a Programar', style: AppText.sans(18, weight: FontWeight.w600, lineHeight: 24)),
            ),
            Text('Ciclo Semanal', style: AppText.sans(16, color: AppColors.onSurfaceVariant, lineHeight: 22)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Text(
                'Semana ${semanaIso(_lunes)} · ${_lunes.day}–${diaMes(_semana.last.fecha)}${_semanaOffset == 0 ? ' (actual)' : ''}',
                style: AppText.sans(15, weight: FontWeight.w600, lineHeight: 20),
              ),
            ),
            FlechaCalendario(Icons.chevron_left,
                etiqueta: 'Semana anterior', onTap: _semanaOffset > 0 ? () => _cambiarSemana(-1) : null),
            const SizedBox(width: 4),
            FlechaCalendario(Icons.chevron_right,
                etiqueta: 'Semana siguiente',
                onTap: _semanaOffset < _semanasAdelante ? () => _cambiarSemana(1) : null),
          ],
        ),
        const SizedBox(height: 12),
        DiaProgramaSelector(
          cortos: [for (final j in _semana) nombreDia(j.fecha).substring(0, 3)],
          completos: [for (final j in _semana) nombreDia(j.fecha)],
          seleccionado: _dia,
          onSelect: (i) => setState(() => _dia = i),
        ),
        const SizedBox(height: 24),
        TurnoCard(
          inicio: _hora('Hora de Inicio', e.inicio,
              const SvgIcon('jornada/hora_inicio.svg', width: 16.7, height: 16.7), (v) => e.inicio = v),
          fin: _hora('Hora de Fin', e.fin, const SvgIcon('jornada/hora_fin.svg', width: 16.7, height: 16.7),
              (v) => e.fin = v),
          valido: e.turnoValido,
          cobertura: '${horas.toStringAsFixed(horas % 1 == 0 ? 0 : 1)} horas brutas',
        ),
        const SizedBox(height: 20),
        AlmuerzoCard(
          activo: e.almuerzo,
          onActivo: (v) => setState(() => e.almuerzo = v),
          inicio: _hora('Inicio de almuerzo', e.almInicio,
              const SvgIcon('jornada/almuerzo_inicio.svg', width: 16.5, height: 16.5), (v) => e.almInicio = v),
          fin: _hora('Fin de almuerzo', e.almFin,
              const SvgIcon('jornada/almuerzo_fin.svg', width: 13.5, height: 13.5), (v) => e.almFin = v),
          valido: e.almuerzoValido,
          okText: 'Pausa comprendida dentro de la jornada laboral (${Jornada.hhmm(e.almInicio)} a '
              '${Jornada.hhmm(e.almFin)} dentro de ${Jornada.hhmm(e.inicio)} - ${Jornada.hhmm(e.fin)}).',
          antes: ((e.almInicio - e.inicio) / total).clamp(0.0, 1.0),
          duracion: ((e.almFin - e.almInicio) / total).clamp(0.0, 1.0),
          duracionMin: e.almFin - e.almInicio,
          netoMin: e.neto,
        ),
        const SizedBox(height: 20),
        AplicarTodosCard(
          aplicar: _aplicarTodos,
          onToggle: () => setState(() => _aplicarTodos = !_aplicarTodos),
          estado: _estadoAgenda,
        ),
        const SizedBox(height: 32),
        HexButton(
          label: 'Guardar Jornada Laboral',
          radius: 2,
          height: 58,
          shadow: AppShadows.medium,
          onPressed: valido ? _guardar : null,
          background: valido ? Colors.black : AppColors.outlineVariant,
          leading: const SvgIcon('jornada/save.svg', width: 15, height: 15),
          textStyle: AppText.sans(18, weight: FontWeight.w600, color: Colors.white, lineHeight: 24),
        ),
      ],
    ));
  }
}
