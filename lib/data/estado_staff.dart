import '../core/reloj.dart';
import '../models/fotografo.dart';
import '../models/jornada.dart';
import 'mock_agenda.dart';
import 'mock_horario.dart';
import 'mock_inasistencias.dart';

const inicioJornadaMin = 8 * 60;
const finJornadaMin = 17 * 60;

EstadoFotografo estadoEnTiempoReal(Fotografo f, {DateTime? ahora}) {
  final a = ahora ?? Reloj.ahora();
  final hoy = DateTime(a.year, a.month, a.day);
  if (f.estado == EstadoFotografo.inactivo ||
      inasistencias.any((i) => i.fotografo == f.nombre && i.cubre(hoy))) {
    return EstadoFotografo.inactivo;
  }
  return estadoPorHorario(f, a);
}

EstadoFotografo estadoPorHorario(Fotografo f, DateTime a) {
  if (sesionesAgenda.any((s) => s.fotografo == f.nombre && s.enCursoEn(a))) return EstadoFotografo.enTurno;
  final m = a.hour * 60 + a.minute;
  if (a.weekday == DateTime.sunday || m < inicioJornadaMin || m >= finJornadaMin) {
    return EstadoFotografo.fueraDeTurno;
  }
  if (m >= almuerzoInicioMin && m < almuerzoInicioMin + Jornada.pausaAlmuerzoMin) return EstadoFotografo.almuerzo;
  return EstadoFotografo.disponible;
}
