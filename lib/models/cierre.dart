import '../extensions/date_time_extensions.dart';
import 'common/json_utils.dart';

enum EstadoCierre { auditado, liquidado }

String codigoCierre(DateTime inicio) =>
    '#CIE-${inicio.year}-${inicio.month.toString().padLeft(2, '0')}${inicio.day <= 15 ? 'A' : 'B'}';

int? _cantidad(Object? v) => v is List ? v.length : parseApiInt(v);

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

  factory Cierre.fromJson(Map<String, dynamic> json) {
    final inicio = fechaDesdeApi(primerCampo(json, ['fechaInicio', 'inicio', 'desde'])) ?? DateTime(2000);
    final fin = fechaDesdeApi(primerCampo(json, ['fechaFin', 'fin', 'hasta'])) ?? inicio;
    final total = parseApiInt(primerCampo(json, ['totalFacturado', 'total', 'valorTotal', 'totalServicios'])) ?? 0;
    final staff =
        parseApiInt(primerCampo(json, ['totalComisiones', 'comisiones', 'valorComisiones', 'totalComision'])) ?? 0;
    final estado = '${campo(json, 'estado') ?? ''}'.toLowerCase();
    final profesionales = primerCampo(json, ['profesionales', 'fotografos']);
    return Cierre(
      id: parseApiInt(primerCampo(json, ['id', 'liquidacionId', 'cierreId'])),
      codigo: codigoCierre(inicio),
      quincena: inicio.day <= 15 ? 1 : 2,
      inicio: inicio,
      fin: fin,
      estado: estado.contains('pag') || estado.contains('liquid') ? EstadoCierre.liquidado : EstadoCierre.auditado,
      servicios: _cantidad(primerCampo(json, ['cantidadServicios', 'servicios', 'totalReservas'])) ?? 0,
      total: total,
      staff: staff,
      fotografos: [
        for (final p in profesionales is List ? profesionales : const [])
          if (p is Map) [campo(p, 'nombres'), campo(p, 'apellidos')].where((x) => x != null).join(' ') else '$p',
      ],
    );
  }

  final int? id;

  final String codigo;

  final int quincena;
  final DateTime inicio;
  final DateTime fin;
  final EstadoCierre estado;

  final int servicios;

  final int total;
  final int staff;

  final List<String> fotografos;

  int get estudio => total - staff;
}

({DateTime inicio, DateTime fin}) quincenaDe(DateTime dia) => dia.day <= 15
    ? (inicio: DateTime(dia.year, dia.month, 1), fin: DateTime(dia.year, dia.month, 15))
    : (inicio: DateTime(dia.year, dia.month, 16), fin: DateTime(dia.year, dia.month + 1, 0));

({DateTime inicio, DateTime fin}) quincenaAnterior(DateTime inicio) =>
    quincenaDe(inicio.subtract(const Duration(days: 1)));

({DateTime inicio, DateTime fin}) ultimaQuincenaCerrable(DateTime hoy) {
  final actual = quincenaDe(hoy);
  return actual.fin.isAfter(hoy) ? quincenaAnterior(actual.inicio) : actual;
}
