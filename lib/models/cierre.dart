enum EstadoCierre { auditado, liquidado }

/// Cierre contable quincenal: consolida los servicios realizados en el rango.
class Cierre {
  const Cierre({
    required this.codigo,
    required this.quincena,
    required this.inicio,
    required this.fin,
    required this.estado,
    required this.servicios,
    required this.total,
    required this.staff,
    this.fotografos = const [],
    this.id,
  });

  /// Id de la liquidación en la API (null en los cierres de ejemplo).
  final int? id;

  /// "#CIE-2026-10A"
  final String codigo;

  /// 1 (días 1–15) o 2 (16–fin de mes).
  final int quincena;
  final DateTime inicio;
  final DateTime fin;
  final EstadoCierre estado;

  /// Servicios realizados incluidos.
  final int servicios;

  /// Facturado y comisiones del staff, en COP.
  final int total;
  final int staff;

  /// Nombres completos de los fotógrafos liquidados.
  final List<String> fotografos;

  int get estudio => total - staff;
}

/// Quincena que contiene [dia]: del 1 al 15, o del 16 al último día del mes.
({DateTime inicio, DateTime fin}) quincenaDe(DateTime dia) => dia.day <= 15
    ? (inicio: DateTime(dia.year, dia.month, 1), fin: DateTime(dia.year, dia.month, 15))
    : (inicio: DateTime(dia.year, dia.month, 16), fin: DateTime(dia.year, dia.month + 1, 0));

/// Quincena inmediatamente anterior a la que empieza en [inicio].
({DateTime inicio, DateTime fin}) quincenaAnterior(DateTime inicio) =>
    quincenaDe(inicio.subtract(const Duration(days: 1)));

/// Última quincena ya terminada a [hoy] (si hoy es el último día de la quincena, cuenta como terminada).
({DateTime inicio, DateTime fin}) ultimaQuincenaCerrable(DateTime hoy) {
  final actual = quincenaDe(hoy);
  return actual.fin.isAfter(hoy) ? quincenaAnterior(actual.inicio) : actual;
}
