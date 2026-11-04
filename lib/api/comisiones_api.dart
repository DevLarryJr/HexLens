import '../models/cierre.dart';
import '../models/fotografo.dart';
import '../models/liquidacion.dart';
import 'api.dart';
import 'reservas_api.dart';

/// Cantidad: un número o el largo de una lista.
int? _cantidad(Object? v) => v is List ? v.length : entero(v);

/// Código del cierre para un rango: "#CIE-2026-10A" (días 1–15) o "…10B" (16 en adelante).
String codigoCierre(DateTime inicio) =>
    '#CIE-${inicio.year}-${inicio.month.toString().padLeft(2, '0')}${inicio.day <= 15 ? 'A' : 'B'}';

/// Cierre de la app a partir de una liquidación de la API (`/api/liquidaciones-comisiones`).
Cierre cierreDesdeApi(Map json) {
  final inicio = fechaDesdeApi(primerCampo(json, ['fechaInicio', 'inicio', 'desde'])) ?? DateTime(2000);
  final fin = fechaDesdeApi(primerCampo(json, ['fechaFin', 'fin', 'hasta'])) ?? inicio;
  final total = entero(primerCampo(json, ['totalFacturado', 'total', 'valorTotal', 'totalServicios'])) ?? 0;
  final staff = entero(primerCampo(json, ['totalComisiones', 'comisiones', 'valorComisiones', 'totalComision'])) ?? 0;
  final estado = '${campo(json, 'estado') ?? ''}'.toLowerCase();
  final profesionales = primerCampo(json, ['profesionales', 'fotografos']);
  return Cierre(
    id: entero(primerCampo(json, ['id', 'liquidacionId', 'cierreId'])),
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

/// Sesión liquidada a partir de un servicio de una comisión (`/api/comisiones/{id}/servicios`).
SesionLiquidada sesionLiquidadaDesdeApi(Map json) {
  final cliente = primerCampo(json, ['cliente', 'clienteNombre', 'nombreCliente']);
  final servicio = primerCampo(json, ['servicio', 'servicioNombre', 'nombreServicio']);
  final id = entero(primerCampo(json, ['reservaId', 'id']));
  final fecha = fechaDesdeApi(primerCampo(json, ['fecha', 'fechaReserva', 'fechaHora'])) ?? DateTime(2000);
  return SesionLiquidada(
    nombreDe(cliente).isEmpty ? 'Cliente' : nombreDe(cliente),
    id == null ? '' : '#RSV-${fecha.year}-${id.toString().padLeft(3, '0')}',
    nombreDe(servicio).isEmpty ? 'Servicio' : nombreDe(servicio),
    fecha,
    entero(primerCampo(json, ['tarifa', 'precio', 'valor', 'total'])) ??
        (servicio is Map ? entero(campo(servicio, 'precio')) : null) ??
        0,
  );
}

/// `GET /api/liquidaciones-comisiones`.
Future<List<Map>> obtenerLiquidacionesApi() async {
  final datos = await Api.get('/api/liquidaciones-comisiones');
  final lista = datos is List ? datos : (datos is Map ? [datos] : const []);
  return [for (final l in lista) if (l is Map) l];
}

/// `POST /api/liquidaciones-comisiones` `{fechaInicio, fechaFin}`: genera la liquidación del rango.
Future<Map> crearLiquidacionApi(DateTime inicio, DateTime fin) async {
  final cuerpo = {'fechaInicio': diaParaApi(inicio), 'fechaFin': diaParaApi(fin)};
  final datos = await Api.post('/api/liquidaciones-comisiones', cuerpo);
  return datos is Map ? {...cuerpo, ...datos} : cuerpo;
}

/// Comisiones de una liquidación: `GET /api/comisiones?cierreId=…`, y por cada una sus servicios
/// (`GET /api/comisiones/{id}/servicios`) si no vienen incluidos. [fotografoDe] traduce el profesional de la API
/// (objeto, nombre o id) a un fotógrafo de la app.
Future<List<Liquidacion>> obtenerComisionesApi(int cierreId, {required Fotografo Function(Object? profesional, int? porcentaje) fotografoDe}) async {
  final datos = await Api.get('/api/comisiones?cierreId=$cierreId');
  final lista = [for (final c in datos is List ? datos : const []) if (c is Map) c];
  return [
    for (final c in lista)
      Liquidacion(
        fotografoDe(primerCampo(c, ['profesional', 'profesionalNombre', 'nombreProfesional', 'profesionalId']),
            entero(primerCampo(c, ['porcentaje', 'tasa']))),
        await _serviciosDe(c),
      ),
  ];
}

Future<List<SesionLiquidada>> _serviciosDe(Map comision) async {
  final incluidos = primerCampo(comision, ['servicios', 'reservas', 'detalle']);
  if (incluidos is List) return [for (final s in incluidos) if (s is Map) sesionLiquidadaDesdeApi(s)];
  final id = entero(campo(comision, 'id'));
  if (id == null) return const [];
  final datos = await Api.get('/api/comisiones/$id/servicios');
  return [for (final s in datos is List ? datos : const []) if (s is Map) sesionLiquidadaDesdeApi(s)];
}
