enum TipoInasistencia { capacitacion, citaMedica, licencia }

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

  final String categoria;
  final String titulo;

  final DateTime desde;
  final DateTime hasta;

  final String horario;

  final String? area;
  final String? motivo;

  final bool adjunto;

  int get dias => hasta.difference(desde).inDays + 1;

  bool vigenteEn(DateTime hoy) => !DateTime(hasta.year, hasta.month, hasta.day).isBefore(DateTime(hoy.year, hoy.month, hoy.day));

  bool cubre(DateTime dia) {
    final d = DateTime(dia.year, dia.month, dia.day);
    return !d.isBefore(DateTime(desde.year, desde.month, desde.day)) && vigenteEn(d);
  }
}
