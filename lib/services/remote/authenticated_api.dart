import '../../config/app_config.dart';
import '../local/sesion_actual.dart';
import 'api_service.dart';

abstract class AuthenticatedApi {
  AuthenticatedApi({ApiService? api, String? token})
    : api = api ?? ApiService(baseUrl: AppConfig.apiBaseUrl, onUnauthorized: SesionActual.cerrar),
      token = token ?? SesionActual.token;

  final ApiService api;
  final String? token;

  Map<String, String> get authHeaders {
    final current = token?.trim();
    if (current == null || current.isEmpty) {
      throw const SessionException();
    }
    return <String, String>{'Authorization': 'Bearer $current'};
  }
}

Object? desenvuelveRespuestaApi(Object? json) =>
    json is Map && json.containsKey('data') ? json['data'] : json;

List<T> parseJsonList<T>(Object? json, T Function(Map<String, dynamic>) fromJson) {
  final contenido = desenvuelveRespuestaApi(json);
  final filas = contenido is List ? contenido : const [];
  return _convertir(() => [
    for (final fila in filas)
      if (fila is Map) fromJson(Map<String, dynamic>.from(fila)),
  ]);
}

T parseJsonObject<T>(Object? json, T Function(Map<String, dynamic>) fromJson) {
  final contenido = desenvuelveRespuestaApi(json);
  if (contenido is! Map) {
    throw const ApiParseException('La respuesta del servidor no es un objeto válido.');
  }
  return _convertir(() => fromJson(Map<String, dynamic>.from(contenido)));
}

Map<String, dynamic> objetoDeRespuesta(Object? json) {
  final contenido = desenvuelveRespuestaApi(json);
  return contenido is Map ? Map<String, dynamic>.from(contenido) : <String, dynamic>{};
}

T _convertir<T>(T Function() convertir) {
  try {
    return convertir();
  } on ApiException {
    rethrow;
  } on FormatException catch (e) {
    throw ApiParseException(e.message);
  } catch (e) {
    throw ApiParseException('La respuesta del servidor no tiene el formato esperado ($e).');
  }
}
