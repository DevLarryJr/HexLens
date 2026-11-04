import '../core/reloj.dart';
import '../models/fotografo.dart';
import '../models/jornada.dart';
import 'mock_agenda.dart';
import 'mock_horario.dart';
import 'mock_inasistencias.dart';

/// Inicio y fin de la jornada del estudio (lunes a sábado), en minutos desde la medianoche.
const inicioJornadaMin = 8 * 60;
const finJornadaMin = 17 * 60;

/// Estado de [f] según la hora real: inactivo (de base o con una inasistencia vigente hoy),
/// en turno (en una sesión ahora), fuera de turno (noche o domingo), almuerzo o disponible.
EstadoFotografo estadoEnTiempoReal(Fotografo f, {DateTime? ahora}) {
  final a = ahora ?? Reloj.ahora();
  final hoy = DateTime(a.year, a.month, a.day);
  if (f.estado == EstadoFotografo.inactivo ||
      inasistencias.any((i) => i.fotografo == f.nombre && i.cubre(hoy))) {
    return EstadoFotografo.inactivo;
  }
  return estadoPorHorario(f, a);
}

/// Estado por horario, sin considerar inactividad.
EstadoFotografo estadoPorHorario(Fotografo f, DateTime a) {
  if (sesionesAgenda.any((s) => s.fotografo == f.nombre && s.enCursoEn(a))) return EstadoFotografo.enTurno;
  final m = a.hour * 60 + a.minute;
  if (a.weekday == DateTime.sunday || m < inicioJornadaMin || m >= finJornadaMin) {
    return EstadoFotografo.fueraDeTurno;
  }
  if (m >= almuerzoInicioMin && m < almuerzoInicioMin + Jornada.pausaAlmuerzoMin) return EstadoFotografo.almuerzo;
  return EstadoFotografo.disponible;
}
