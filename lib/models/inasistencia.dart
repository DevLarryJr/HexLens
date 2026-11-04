enum TipoInasistencia { capacitacion, citaMedica, licencia }

/// Periodo en que un fotógrafo no está disponible para reservas.
class Inasistencia {
  const Inasistencia({
    required this.id,
    required this.fotografo,
    required this.tipo,
    required this.categoria,
    required this.titulo,
    required this.desde,
    required this.hasta,
    required this.horario,
    this.area,
    this.motivo,
    this.adjunto = false,
  });

  final String id;
  final String fotografo;
  final TipoInasistencia tipo;

  /// Etiqueta en mayúsculas (el salto de línea viene del diseño).
  final String categoria;
  final String titulo;

  /// Primer y último día (inclusive).
  final DateTime desde;
  final DateTime hasta;

  /// Franja bloqueada: "08:00 - 19:00".
  final String horario;

  /// Área de trabajo afectada (licencias).
  final String? area;
  final String? motivo;

  /// Tiene documento de soporte adjunto.
  final bool adjunto;

  int get dias => hasta.difference(desde).inDays + 1;

  /// Sigue vigente (no ha terminado) en la fecha [hoy].
  bool vigenteEn(DateTime hoy) => !DateTime(hasta.year, hasta.month, hasta.day).isBefore(DateTime(hoy.year, hoy.month, hoy.day));

  /// El fotógrafo está ausente en la fecha [dia] (ya empezó y no ha terminado).
  bool cubre(DateTime dia) {
    final d = DateTime(dia.year, dia.month, dia.day);
    return !d.isBefore(DateTime(desde.year, desde.month, desde.day)) && vigenteEn(d);
  }
}
