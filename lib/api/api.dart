import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Dirección de la API de Ehily (la del entorno "Produccion" de la colección de Bruno).
const urlApi = 'https://api.ehily.cecar.cloud';

/// Error devuelto por la API (o por la conexión), con un mensaje listo para mostrar al usuario.
class ApiError implements Exception {
  const ApiError(this.mensaje, {this.estado, this.codigo});

  final String mensaje;

  /// Código HTTP (401, 404…); null si no hubo respuesta (sin internet, servidor caído).
  final int? estado;

  /// Código de la API, p. ej. "CLIENTS_RETRIEVED".
  final String? codigo;

  /// El token venció o no es válido: hay que volver a iniciar sesión.
  bool get sesionVencida => estado == 401;

  @override
  String toString() => mensaje;
}

/// Datos de la sesión iniciada, sacados del token (JWT) que entrega la API.
class SesionApi {
  const SesionApi({required this.token, required this.usuario, required this.rol, this.empresaId, this.empresa, this.vence});

  final String token;

  /// Usuario con el que se inició sesión (la cédula).
  final String usuario;

  /// "Gestor", "Profesional"…
  final String rol;
  final String? empresaId;

  /// Nombre de la empresa en la API, p. ej. "Hex Lens".
  final String? empresa;
  final DateTime? vence;

  /// El rol entra al panel administrativo (el resto, a "Mis Servicios").
  bool get esGestor {
    final r = rol.toLowerCase();
    return r.contains('gestor') || r.contains('admin');
  }

  /// Lee los datos del token sin verificar su firma (eso lo hace la API en cada petición).
  factory SesionApi.desdeToken(String token) {
    final partes = token.split('.');
    Map<String, dynamic> datos = const {};
    if (partes.length == 3) {
      try {
        datos = jsonDecode(utf8.decode(base64Url.decode(base64Url.normalize(partes[1])))) as Map<String, dynamic>;
      } on FormatException {
        // Token sin datos legibles: se usa igual, la API decide si es válido.
      }
    }
    final rol = datos['http://schemas.microsoft.com/ws/2008/06/identity/claims/role'] ?? datos['role'] ?? datos['rol'];
    final exp = datos['exp'];
    return SesionApi(
      token: token,
      usuario: '${datos['usuario'] ?? datos['sub'] ?? ''}',
      rol: '${rol ?? ''}',
      empresaId: datos['empresaId']?.toString(),
      empresa: datos['empresaNombre']?.toString(),
      vence: exp is num ? DateTime.fromMillisecondsSinceEpoch(exp.toInt() * 1000) : null,
    );
  }
}

/// Cliente HTTP de la API: inicia sesión, guarda el token y lo envía en cada petición.
/// Las respuestas llegan como `{ success, code, message, data }` y se devuelve `data`.
class Api {
  Api._();

  /// Se puede reemplazar en las pruebas por un `MockClient`.
  static http.Client cliente = http.Client();

  static SesionApi? _sesion;

  /// Sesión actual; null si no se ha iniciado (la app usa entonces los datos de ejemplo).
  static SesionApi? get sesion => _sesion;
  static bool get conectada => _sesion != null;

  static const _claveToken = 'api_token';
  static const _espera = Duration(seconds: 20);

  /// `POST /api/sesion`. Lanza [ApiError] si el usuario o la clave no son válidos.
  static Future<SesionApi> iniciarSesion(String usuario, String clave) async {
    final respuesta = await _peticion('POST', '/api/sesion', {'Usuario': usuario.trim(), 'Clave': clave}, conToken: false);
    final cuerpo = respuesta is Map ? respuesta : const {};
    final datos = cuerpo['data'] is Map ? cuerpo['data'] as Map : const {};
    final token = cuerpo['accessToken'] ?? cuerpo['token'] ?? datos['accessToken'] ?? datos['token'];
    if (token is! String || token.isEmpty) {
      throw const ApiError('La API no devolvió un token de acceso.');
    }
    final sesion = SesionApi.desdeToken(token);
    _sesion = sesion;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveToken, token);
    return sesion;
  }

  /// Olvida el token (al cerrar sesión o cuando vence).
  static Future<void> cerrarSesion() async {
    _sesion = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveToken);
  }

  static Future<dynamic> get(String ruta) async => _datos(await _enviar('GET', ruta));
  static Future<dynamic> post(String ruta, Map<String, dynamic> cuerpo) async => _datos(await _enviar('POST', ruta, cuerpo));
  static Future<dynamic> put(String ruta, Map<String, dynamic> cuerpo) async => _datos(await _enviar('PUT', ruta, cuerpo));
  static Future<dynamic> delete(String ruta) async => _datos(await _enviar('DELETE', ruta));

  /// `data` de la respuesta (o la respuesta entera si no viene envuelta).
  static dynamic _datos(dynamic respuesta) => respuesta is Map && respuesta.containsKey('data') ? respuesta['data'] : respuesta;

  static Future<dynamic> _enviar(String metodo, String ruta, [Map<String, dynamic>? cuerpo]) =>
      _peticion(metodo, ruta, cuerpo, conToken: true);

  static Future<dynamic> _peticion(String metodo, String ruta, Map<String, dynamic>? cuerpo,
      {required bool conToken}) async {
    final peticion = http.Request(metodo, Uri.parse('$urlApi$ruta'))
      ..headers['Accept'] = 'application/json';
    if (conToken) {
      final sesion = _sesion;
      if (sesion == null) throw const ApiError('Inicia sesión para consultar la API.', estado: 401);
      peticion.headers['Authorization'] = 'Bearer ${sesion.token}';
    }
    if (cuerpo != null) {
      peticion.headers['Content-Type'] = 'application/json';
      peticion.body = jsonEncode(cuerpo);
    }

    final http.Response respuesta;
    try {
      respuesta = await http.Response.fromStream(await cliente.send(peticion).timeout(_espera));
    } catch (_) {
      throw const ApiError('No se pudo conectar con el servidor. Revisa tu conexión a internet.');
    }

    dynamic json;
    if (respuesta.body.isNotEmpty) {
      try {
        json = jsonDecode(utf8.decode(respuesta.bodyBytes));
      } on FormatException {
        json = null;
      }
    }
    final mapa = json is Map ? json : const {};
    final exito = respuesta.statusCode >= 200 && respuesta.statusCode < 300 && mapa['success'] != false;
    if (exito) return json;

    if (respuesta.statusCode == 401 && conToken) await cerrarSesion();
    throw ApiError(
      _mensajeDeError(respuesta.statusCode, mapa, conToken: conToken),
      estado: respuesta.statusCode,
      codigo: mapa['code']?.toString(),
    );
  }

  static String _mensajeDeError(int estado, Map mapa, {required bool conToken}) {
    final mensaje = mapa['message'] ?? mapa['title'] ?? mapa['error'];
    if (mensaje is String && mensaje.trim().isNotEmpty) return mensaje;
    return switch (estado) {
      400 => 'Los datos enviados no son válidos.',
      401 => conToken ? 'Tu sesión venció. Vuelve a iniciar sesión.' : 'Usuario o clave incorrectos.',
      403 => 'No tienes permiso para hacer esto.',
      404 => 'No se encontró lo que buscas.',
      409 => 'Ya existe un registro con esos datos.',
      >= 500 => 'El servidor tuvo un problema. Intenta de nuevo en un momento.',
      _ => 'Error $estado al consultar la API.',
    };
  }
}

/// Valor de [json] para [nombre] sin importar mayúsculas ("Nombres", "nombres" o "NOMBRES"):
/// la API puede responder en PascalCase o camelCase.
dynamic campo(Map json, String nombre) {
  if (json.containsKey(nombre)) return json[nombre];
  final buscado = nombre.toLowerCase();
  for (final e in json.entries) {
    if ('${e.key}'.toLowerCase() == buscado) return e.value;
  }
  return null;
}

/// Número entero de un valor de la API, venga como número (90000 o 90000.0) o como texto; null si no es número.
int? entero(Object? v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}'.split('.').first);

/// Primer valor no nulo de [json] entre varios nombres de campo posibles (la API no siempre usa el mismo).
dynamic primerCampo(Map json, List<String> nombres) {
  for (final n in nombres) {
    final v = campo(json, n);
    if (v != null) return v;
  }
  return null;
}

/// Nombre de una persona o cosa que la API manda como texto o como objeto (`{nombres, apellidos}` o `{nombre}`).
String nombreDe(Object? v) {
  if (v is Map) {
    final completo = [campo(v, 'nombres'), campo(v, 'apellidos')]
        .where((p) => p != null && '$p'.trim().isNotEmpty)
        .join(' ');
    return completo.isNotEmpty ? completo : '${campo(v, 'nombre') ?? ''}'.trim();
  }
  return '${v ?? ''}'.trim();
}
