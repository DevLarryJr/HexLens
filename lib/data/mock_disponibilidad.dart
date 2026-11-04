import '../core/reloj.dart';
import '../models/bloque_horario.dart';
import '../utils/formato.dart';
import 'mock_agenda.dart';

/// Días que muestra el selector de fecha de la reserva: de ayer a pasado mañana.
List<DateTime> get diasReserva => [for (var d = -1; d <= 2; d++) Reloj.dia(d)];

/// Jornada de Laura Méndez por día (08:00 - 17:00, almuerzo 13:00 - 14:00).
/// Hoy, los bloques libres cuya hora ya pasó se marcan [BloqueTipo.pasado].
List<BloqueHorario> bloquesDelDia(DateTime dia) {
  DateTime h(int hora, [int min = 0]) => DateTime(dia.year, dia.month, dia.day, hora, min);
  final almuerzo = BloqueHorario(h(13), BloqueTipo.almuerzo, 'Receso técnico del fotógrafo', duracionMin: 60);

  final List<BloqueHorario> bloques;
  if (mismoDia(dia, Reloj.hoy)) {
    bloques = [
      BloqueHorario(h(8, 30), BloqueTipo.ocupado, 'Sesión Daniel Castro', duracionMin: 45),
      BloqueHorario(h(10), BloqueTipo.libre, 'Óptimo para luz natural cenital'),
      BloqueHorario(h(11), BloqueTipo.libre, 'Intervalo libre 15 min tras sesión'),
      BloqueHorario(h(12), BloqueTipo.libre, 'Último bloque antes de refrigerio'),
      almuerzo,
      BloqueHorario(h(14, 15), BloqueTipo.libre, 'Turno de tarde'),
      BloqueHorario(h(15, 30), BloqueTipo.libre, 'Último turno disponible'),
    ];
  } else if (mismoDia(dia, diaHabil(2))) {
    bloques = [
      BloqueHorario(h(8, 30), BloqueTipo.ocupado, 'Sesión Familia Ortiz', duracionMin: 90),
      BloqueHorario(h(10, 30), BloqueTipo.libre, 'Único bloque de la mañana'),
      BloqueHorario(h(11, 30), BloqueTipo.ocupado, 'Sesión Revista Lumen', duracionMin: 90),
      almuerzo,
      BloqueHorario(h(14, 15), BloqueTipo.ocupado, 'Sesión Juliana Rojas', duracionMin: 45),
      BloqueHorario(h(15, 30), BloqueTipo.libre, 'Último turno disponible'),
    ];
  } else {
    bloques = [
      BloqueHorario(h(9), BloqueTipo.libre, 'Primer turno de la jornada'),
      BloqueHorario(h(10), BloqueTipo.libre, 'Óptimo para luz natural cenital'),
      BloqueHorario(h(11), BloqueTipo.libre, 'Intervalo libre 15 min tras sesión'),
      BloqueHorario(h(12), BloqueTipo.libre, 'Último bloque antes de refrigerio'),
      almuerzo,
      BloqueHorario(h(14, 15), BloqueTipo.libre, 'Turno de tarde'),
      BloqueHorario(h(15, 30), BloqueTipo.libre, 'Último turno disponible'),
    ];
  }

  final ahora = Reloj.ahora();
  return [
    for (final b in bloques)
      b.libre && b.inicio.isBefore(ahora)
          ? BloqueHorario(b.inicio, BloqueTipo.pasado, 'Horario ya transcurrido')
          : b,
  ];
}
