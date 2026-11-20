import '../../config/api_paths.dart';
import '../../extensions/date_time_extensions.dart';
import '../../models/common/json_utils.dart';
import '../../models/reserva/reserva_request.dart';
import '../../models/sesion.dart';
import 'authenticated_api.dart';

class ReservasApi extends AuthenticatedApi {
  ReservasApi({super.api, super.token});

  Future<List<Sesion>> listar({
    required DateTime desde,
    required DateTime hasta,
    NombreCliente? nombreCliente,
    ServicioPorId? servicioPorId,
  }) async {
    final json = await api.get(
      ApiPaths.reservas,
      queryParameters: {
        'FechaInicio': desde.toIsoDateString(),
        'FechaFin': hasta.toIsoDateString(),
      },
      headers: authHeaders,
    );
    return parseJsonList(
      json,
      (r) => Sesion.fromJson(r, nombreCliente: nombreCliente, servicioPorId: servicioPorId),
    );
  }

  Future<Sesion> crear(
    CrearReservaRequest request, {
    NombreCliente? nombreCliente,
    ServicioPorId? servicioPorId,
  }) async {
    final json = await api.post(ApiPaths.reservas, body: request.toJson(), headers: authHeaders);
    return Sesion.fromJson(
      {...request.toJson(), ...objetoDeRespuesta(json)},
      nombreCliente: nombreCliente,
      servicioPorId: servicioPorId,
    );
  }

  Future<void> actualizar(int id, EditarReservaRequest request) async {
    await api.put(ApiPaths.reserva(id), body: request.toJson(), headers: authHeaders);
  }

  Future<void> cancelar(int id) async {
    await api.delete(ApiPaths.reserva(id), headers: authHeaders);
  }

  Future<List<DateTime>> consultarHorarios(DateTime dia, int servicioId, {int? profesionalId}) async {
    final json = await api.get(
      ApiPaths.agenda,
      queryParameters: {
        'fecha': dia.toIsoDateString(),
        'servicioId': servicioId,
        'profesionalId': profesionalId,
      },
      headers: authHeaders,
    );
    return horasDesdeApi(desenvuelveRespuestaApi(json), dia);
  }
}

List<DateTime> horasDesdeApi(Object? datos, DateTime dia) {
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
