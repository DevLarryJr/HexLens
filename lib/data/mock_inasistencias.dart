import '../core/reloj.dart';
import '../models/inasistencia.dart';

/// Inasistencias registradas del staff, ancladas a hoy: una capacitación en dos semanas, una cita médica
/// hace 11 días y una licencia que cubre todo el mes en curso.
final inasistencias = [
  Inasistencia(
    id: 'INA-031',
    fotografo: 'Laura Méndez',
    tipo: TipoInasistencia.capacitacion,
    categoria: 'CAPACITACIÓN\nINSTITUCIONAL',
    titulo: 'Capacitación Técnica Iluminación Profoto',
    desde: Reloj.dia(13),
    hasta: Reloj.dia(14),
    horario: '08:00 - 19:00',
  ),
  Inasistencia(
    id: 'INA-027',
    fotografo: 'Laura Méndez',
    tipo: TipoInasistencia.citaMedica,
    categoria: 'CITA MÉDICA\nCERTIFICADA',
    titulo: 'Permiso Médico Odontológico',
    desde: Reloj.dia(-11),
    hasta: Reloj.dia(-11),
    horario: '08:00 — 12:00 (Medio día)',
    adjunto: true,
  ),
  Inasistencia(
    id: 'INA-025',
    fotografo: 'Nicolás Vega',
    tipo: TipoInasistencia.licencia,
    categoria: 'LICENCIA',
    titulo: 'Licencia Temporal Editorial',
    desde: DateTime(Reloj.hoy.year, Reloj.hoy.month, 1),
    hasta: DateTime(Reloj.hoy.year, Reloj.hoy.month + 1, 0),
    horario: '',
    area: 'Comercial /\nModa',
    motivo: 'Viaje y cobertura fuera de la ciudad (Milán Fashion Lab)',
  ),
];

/// Quita las inasistencias de [fotografo] que cubren [dia] (vuelve a trabajar ese día).
void liberarAusencias(String fotografo, DateTime dia) =>
    inasistencias.removeWhere((i) => i.fotografo == fotografo && i.cubre(dia));
