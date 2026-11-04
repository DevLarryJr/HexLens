import '../core/reloj.dart';
import '../models/franja_horaria.dart';
import '../models/opcion_staff.dart';
import '../models/sesion.dart';
import '../utils/formato.dart';
import 'mock_agenda.dart';
import 'mock_inasistencias.dart';

/// Operadores a los que se puede reasignar la sesión en la franja [hora].
List<OpcionStaff> opcionesStaffReagendar(String hora) => [
      const OpcionStaff(
        nombre: 'Laura Méndez (Titular actual)',
        detalle: 'Cabina 02 · Disponible ahora',
        etiqueta: '98%\nafinidad',
      ),
      OpcionStaff(
        nombre: 'Mateo Ríos (Iluminación)',
        detalle: 'Sin conflicto en franja de $hora',
        etiqueta: 'Sénior',
      ),
      const OpcionStaff(
        nombre: 'Cualquier disponible',
        detalle: 'Se asigna al fotógrafo con menos carga',
        etiqueta: 'AUTO',
        automatica: true,
      ),
    ];

/// Hasta cuántos meses hacia adelante se puede reagendar.
const mesesReagendar = 6;

/// Horas de inicio que ofrece el estudio para reagendar; la de las 5:00 PM es el cierre.
const _horas = [(9, 0), (10, 0), (11, 30), (14, 15), (15, 45), (17, 0)];

/// El día no admite sesiones: ya pasó, es domingo (estudio cerrado) o el fotógrafo está ausente.
bool diaBloqueadoReagendar(DateTime dia, String fotografo) =>
    dia.isBefore(Reloj.hoy) ||
    dia.weekday == DateTime.sunday ||
    inasistencias.any((i) => i.fotografo == fotografo && i.cubre(dia));

/// Franjas de [dia] para mover [sesion]: "OCUPADO" si el fotógrafo ya tiene otra sesión que se cruza,
/// "PASADO" si la hora ya pasó (hoy) y "CIERRE" la última del día.
List<FranjaHoraria> franjasReagendar(DateTime dia, Sesion sesion) {
  final otras = sesionesAgenda.where((s) =>
      !identical(s, sesion) && !s.cancelada && s.fotografo == sesion.fotografo && mismoDia(s.inicio, dia));
  return [
    for (final (h, m) in _horas)
      () {
        final inicio = DateTime(dia.year, dia.month, dia.day, h, m);
        final fin = inicio.add(Duration(minutes: sesion.duracionMin));
        final String? bloqueo;
        if (h >= 17) {
          bloqueo = 'CIERRE';
        } else if (inicio.isBefore(Reloj.ahora())) {
          bloqueo = 'PASADO';
        } else if (otras.any((s) => s.inicio.isBefore(fin) && s.fin.isAfter(inicio))) {
          bloqueo = 'OCUPADO';
        } else {
          bloqueo = null;
        }
        return FranjaHoraria(horaAmPm(inicio), inicio: inicio, bloqueo: bloqueo);
      }(),
  ];
}
