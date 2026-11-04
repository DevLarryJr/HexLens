import '../models/sesion.dart';
import '../utils/formato.dart';
import 'api.dart';

/// Fecha como la pide la API: "2026-10-30T10:00:00".
String fechaParaApi(DateTime d) =>
    '${d.year}-${dosCifras(d.month)}-${dosCifras(d.day)}T${dosCifras(d.hour)}:${dosCifras(d.minute)}:00';

/// Solo el día, para los filtros: "2026-10-30".
String diaParaApi(DateTime d) => '${d.year}-${dosCifras(d.month)}-${dosCifras(d.day)}';

/// Fecha y hora de un texto de la API ("2026-10-30T10:00:00", "2026-10-30 10:00:00"); null si no es fecha.
/// Se toma como hora local de Colombia (se ignora la zona si viene).
DateTime? fechaDesdeApi(Object? v) {
  final m = RegExp(r'(\d{4})-(\d{2})-(\d{2})(?:[T ](\d{2}):(\d{2}))?').firstMatch('${v ?? ''}');
  if (m == null) return null;
  int g(int i) => int.parse(m.group(i) ?? '0');
  return DateTime(g(1), g(2), g(3), g(4), g(5));
}

/// Estado de la reserva según el texto de la API ("Pendiente", "Confirmada", "Cancelada", "Atendida"…).
SesionEstado estadoDesdeApi(Object? v) {
  final e = sinTildes('${v ?? ''}');
  if (e.contains('cancel') || e.contains('anul')) return SesionEstado.cancelada;
  if (e.contains('atend') || e.contains('complet') || e.contains('realiz') || e.contains('finaliz')) {
    return SesionEstado.realizada;
  }
  return SesionEstado.programada;
}

/// Sesión de la app a partir de una reserva de la API (`/api/reservas`). Acepta el cliente, el servicio y el
/// profesional como objetos, como nombres sueltos o como ids; lo que falte se completa con [nombreServicio],
/// [nombreCliente] y [duracionServicio] (que buscan en las listas ya cargadas).
Sesion sesionDesdeApi(
  Map json, {
  String Function(int? id)? nombreCliente,
  ({String nombre, int duracion, int precio})? Function(int? id)? servicioPorId,
}) {
  final cliente = primerCampo(json, ['cliente', 'clienteNombre', 'nombreCliente']);
  final servicio = primerCampo(json, ['servicio', 'servicioNombre', 'nombreServicio']);
  final profesional = primerCampo(json, ['profesional', 'profesionalNombre', 'nombreProfesional', 'fotografo']);
  final clienteId = entero(primerCampo(json, ['clienteId']) ?? (cliente is Map ? campo(cliente, 'id') : null));
  final servicioId = entero(primerCampo(json, ['servicioId']) ?? (servicio is Map ? campo(servicio, 'id') : null));
  final delCatalogo = servicioPorId?.call(servicioId);

  var nombreDelCliente = nombreDe(cliente);
  if (nombreDelCliente.isEmpty) nombreDelCliente = nombreCliente?.call(clienteId) ?? 'Cliente';
  var nombreDelServicio = servicio is Map ? '${campo(servicio, 'nombre') ?? ''}' : nombreDe(servicio);
  if (nombreDelServicio.isEmpty) nombreDelServicio = delCatalogo?.nombre ?? 'Servicio';
  final duracion = entero(primerCampo(json, ['duracion']) ?? (servicio is Map ? campo(servicio, 'duracion') : null)) ??
      delCatalogo?.duracion ??
      60;
  final precio = entero(primerCampo(json, ['precio', 'valor', 'total']) ?? (servicio is Map ? campo(servicio, 'precio') : null)) ??
      delCatalogo?.precio;
  final id = entero(primerCampo(json, ['id', 'reservaId']));
  final inicio = fechaDesdeApi(primerCampo(json, ['fecha', 'fechaHora', 'fechaInicio', 'inicio'])) ?? DateTime(2000);
  final estado = estadoDesdeApi(campo(json, 'estado'));

  return Sesion(
    id: id,
    clienteId: clienteId,
    servicioId: servicioId,
    codigo: id == null ? null : '#RSV-${inicio.year}-${id.toString().padLeft(3, '0')}',
    inicio: inicio,
    duracionMin: duracion,
    lugar: '${primerCampo(json, ['lugar', 'sede', 'set']) ?? 'Estudio'}',
    cliente: nombreDelCliente,
    servicio: nombreDelServicio,
    descripcion: nombreDelServicio,
    fotografo: nombreDe(profesional).isEmpty ? 'Por asignar' : nombreDe(profesional),
    pago: '${primerCampo(json, ['medioPago', 'pago']) ?? ''}',
    precio: estado == SesionEstado.cancelada ? null : precio,
    estado: estado,
    motivo: estado == SesionEstado.cancelada ? 'Reserva cancelada' : null,
  );
}

/// `GET /api/reservas?FechaInicio=…&FechaFin=…`.
Future<List<Map>> obtenerReservasApi(DateTime desde, DateTime hasta) async {
  final datos = await Api.get('/api/reservas?FechaInicio=${diaParaApi(desde)}&FechaFin=${diaParaApi(hasta)}');
  return [for (final r in datos is List ? datos : const []) if (r is Map) r];
}

/// `POST /api/reservas` para un cliente ya registrado. Devuelve el JSON creado (o lo enviado si no lo devuelve).
Future<Map> crearReservaApi({required DateTime inicio, required int servicioId, required int clienteId}) async {
  final cuerpo = {'Fecha': fechaParaApi(inicio), 'ServicioId': servicioId, 'ClienteId': clienteId};
  final datos = await Api.post('/api/reservas', cuerpo);
  return datos is Map ? {...cuerpo, ...datos} : cuerpo;
}

/// `PUT /api/reservas/{id}`: cambia fecha (y servicio).
Future<void> editarReservaApi(int id, {required DateTime inicio, required int servicioId}) =>
    Api.put('/api/reservas/$id', {'Fecha': fechaParaApi(inicio), 'ServicioId': servicioId});

/// `DELETE /api/reservas/{id}`: cancela la reserva.
Future<void> cancelarReservaApi(int id) => Api.delete('/api/reservas/$id');

/// `GET /api/agenda?fecha=…&servicioId=…`: horas de inicio libres ese día para ese servicio. Acepta una lista
/// de horas ("10:00", "2026-10-30T10:00:00") o de objetos con la hora (`{hora}`, `{horaInicio}`, `{inicio}`…).
/// Con [profesionalId] (`&profesionalId=…`), solo las horas libres de ese profesional.
Future<List<DateTime>> horariosDisponiblesApi(DateTime dia, int servicioId, {int? profesionalId}) async {
  final datos = await Api.get('/api/agenda?fecha=${diaParaApi(dia)}&servicioId=$servicioId'
      '${profesionalId == null ? '' : '&profesionalId=$profesionalId'}');
  final lista = datos is List
      ? datos
      : datos is Map
          ? (primerCampo(datos, ['horarios', 'disponibles', 'horas', 'slots']) as List? ?? const [])
          : const [];
  final horas = <DateTime>{};
  for (final h in lista) {
    final valor = h is Map ? primerCampo(h, ['hora', 'horaInicio', 'inicio', 'fecha', 'fechaHora']) : h;
    final completa = fechaDesdeApi(valor);
    final soloHora = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch('${valor ?? ''}'.trim());
    if (completa != null && '$valor'.contains(RegExp(r'\d{4}-'))) {
      horas.add(DateTime(dia.year, dia.month, dia.day, completa.hour, completa.minute));
    } else if (soloHora != null) {
      horas.add(DateTime(dia.year, dia.month, dia.day, int.parse(soloHora.group(1)!), int.parse(soloHora.group(2)!)));
    }
  }
  return horas.toList()..sort();
}
