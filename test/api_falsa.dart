import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:proyecto_movil/api/api.dart';

/// Credenciales que acepta la API falsa (inventadas, solo para pruebas).
const usuarioPrueba = '1234567890';
const clavePrueba = 'clave-prueba';

/// JWT falso con el rol y la empresa dados (la firma no se verifica en la app).
String tokenFalso({String rol = 'Gestor'}) {
  String parte(Map<String, Object> datos) => base64Url.encode(utf8.encode(jsonEncode(datos))).replaceAll('=', '');
  return [
    parte({'alg': 'HS256', 'typ': 'JWT'}),
    parte({
      'sub': '7',
      'usuario': usuarioPrueba,
      'http://schemas.microsoft.com/ws/2008/06/identity/claims/role': rol,
      'empresaId': '6',
      'empresaNombre': 'Hex Lens',
      'exp': 1893456000,
    }),
    'firma',
  ].join('.');
}

/// Lo que recibió la API falsa (para revisar lo que envía la app).
final peticionesRecibidas = <http.Request>[];

/// Reemplaza el cliente HTTP de [Api] por una API falsa con el formato real de Ehily
/// (`{ success, code, message, data }`). [clientes] es lo que devuelve `GET /api/clientes`.
/// [especialidades] es lo que devuelve `GET /api/especialidades`; la de id [conServicios] no se deja
/// eliminar (como la API real cuando la especialidad tiene servicios asociados).
void usarApiFalsa({
  String rol = 'Gestor',
  List<Map<String, Object?>> clientes = const [],
  List<Map<String, Object?>> especialidades = const [],
  int? conServicios,
  List<Map<String, Object?>> servicios = const [],
  List<Map<String, Object?>> profesionales = const [],
  List<Map<String, Object?>> reservas = const [],
  Object horarios = const ['09:00', '10:30', '14:00'],
  List<Map<String, Object?>> liquidaciones = const [],
  List<Map<String, Object?>> comisiones = const [],
  List<Map<String, Object?>> serviciosDeComision = const [],
}) {
  final liquidacionesGuardadas = [...liquidaciones];
  final reservasGuardadas = [...reservas];
  final profesionalesGuardados = [...profesionales];
  peticionesRecibidas.clear();
  final guardados = [...clientes];
  final especialidadesGuardadas = [...especialidades];
  final serviciosGuardados = [...servicios];
  http.Response json(Object cuerpo, [int estado = 200]) =>
      http.Response(jsonEncode(cuerpo), estado, headers: {'content-type': 'application/json; charset=utf-8'});

  Api.cliente = MockClient((peticion) async {
    peticionesRecibidas.add(peticion);
    final ruta = peticion.url.path;
    if (ruta == '/api/sesion' && peticion.method == 'POST') {
      final cuerpo = jsonDecode(peticion.body) as Map;
      if (cuerpo['Usuario'] == usuarioPrueba && cuerpo['Clave'] == clavePrueba) {
        return json({'accessToken': tokenFalso(rol: rol)});
      }
      return json({'success': false, 'code': 'INVALID_CREDENTIALS', 'message': 'Usuario o clave incorrectos.'}, 401);
    }
    if (peticion.headers['Authorization'] != 'Bearer ${tokenFalso(rol: rol)}') {
      return json({'success': false, 'message': 'Token inválido.'}, 401);
    }
    if (ruta == '/api/clientes' && peticion.method == 'GET') {
      return json({'success': true, 'code': 'CLIENTS_RETRIEVED', 'message': 'Clientes consultados correctamente.', 'data': guardados});
    }
    if (ruta == '/api/clientes' && peticion.method == 'POST') {
      final nuevo = {'id': guardados.length + 1, ...(jsonDecode(peticion.body) as Map<String, Object?>)};
      guardados.add(nuevo);
      return json({'success': true, 'code': 'CLIENT_CREATED', 'message': 'Cliente creado.', 'data': nuevo}, 201);
    }
    final documento = RegExp(r'^/api/clientes/(\d+)$').firstMatch(ruta);
    if (documento != null && peticion.method == 'GET') {
      final existente = guardados.where((c) => '${c['documento'] ?? c['Documento']}' == documento.group(1)).firstOrNull;
      return existente == null
          ? json({'success': false, 'code': 'CLIENT_NOT_FOUND', 'message': 'Cliente no encontrado.'}, 404)
          : json({'success': true, 'code': 'CLIENT_RETRIEVED', 'message': 'OK', 'data': existente});
    }
    final porEspecialidad = RegExp(r'^/api/profesionales/(\d+)/especialiades$').firstMatch(ruta);
    if (porEspecialidad != null) {
      final id = int.parse(porEspecialidad.group(1)!);
      return json({
        'success': true,
        'message': 'OK',
        'data': [for (final p in profesionalesGuardados) if (p['especialidad'] == id) p],
      });
    }
    if (ruta == '/api/especialidades' && peticion.method == 'GET') {
      return json({'success': true, 'code': 'SPECIALTIES_RETRIEVED', 'message': 'OK', 'data': especialidadesGuardadas});
    }
    if (ruta == '/api/especialidades' && peticion.method == 'POST') {
      final nueva = {'id': 100 + especialidadesGuardadas.length, 'nombre': (jsonDecode(peticion.body) as Map)['Nombre']};
      especialidadesGuardadas.add(nueva);
      return json({'success': true, 'code': 'SPECIALTY_CREATED', 'message': 'Especialidad creada.', 'data': nueva}, 201);
    }
    final especialidad = RegExp(r'^/api/especialidades/(\d+)$').firstMatch(ruta);
    if (especialidad != null) {
      final id = int.parse(especialidad.group(1)!);
      if (peticion.method == 'DELETE' && id == conServicios) {
        return json({'success': false, 'message': 'No se puede eliminar: tiene servicios asociados.'}, 409);
      }
      if (peticion.method == 'DELETE') {
        especialidadesGuardadas.removeWhere((e) => e['id'] == id);
        return json({'success': true, 'message': 'Especialidad eliminada.', 'data': null});
      }
      if (peticion.method == 'PUT') {
        return json({'success': true, 'message': 'Especialidad actualizada.', 'data': null});
      }
    }
    if (ruta == '/api/servicios' && peticion.method == 'GET') {
      return json({'success': true, 'code': 'SERVICES_RETRIEVED', 'message': 'OK', 'data': serviciosGuardados});
    }
    if (ruta == '/api/servicios' && peticion.method == 'POST') {
      final nuevo = {'id': 200 + serviciosGuardados.length, ...(jsonDecode(peticion.body) as Map<String, Object?>)};
      serviciosGuardados.add(nuevo);
      return json({'success': true, 'code': 'SERVICE_CREATED', 'message': 'Servicio creado.', 'data': nuevo}, 201);
    }
    if (RegExp(r'^/api/servicios/\d+$').hasMatch(ruta) && (peticion.method == 'PUT' || peticion.method == 'DELETE')) {
      return json({'success': true, 'message': 'OK', 'data': null});
    }
    if (ruta == '/api/profesionales' && peticion.method == 'GET') {
      return json({'success': true, 'code': 'PROFESSIONALS_RETRIEVED', 'message': 'OK', 'data': profesionalesGuardados});
    }
    if (ruta == '/api/profesionales' && peticion.method == 'POST') {
      final nuevo = {'id': 300 + profesionalesGuardados.length, ...(jsonDecode(peticion.body) as Map<String, Object?>)};
      profesionalesGuardados.add(nuevo);
      return json({'success': true, 'code': 'PROFESSIONAL_CREATED', 'message': 'Profesional creado.', 'data': nuevo}, 201);
    }
    if (RegExp(r'^/api/profesionales/\d+$').hasMatch(ruta) && (peticion.method == 'PUT' || peticion.method == 'DELETE')) {
      return json({'success': true, 'message': 'OK', 'data': null});
    }
    if (ruta == '/api/reservas' && peticion.method == 'GET') {
      return json({'success': true, 'code': 'BOOKINGS_RETRIEVED', 'message': 'OK', 'data': reservasGuardadas});
    }
    if (ruta == '/api/reservas' && peticion.method == 'POST') {
      final nueva = {'id': 400 + reservasGuardadas.length, 'estado': 'Pendiente', ...(jsonDecode(peticion.body) as Map<String, Object?>)};
      reservasGuardadas.add(nueva);
      return json({'success': true, 'code': 'BOOKING_CREATED', 'message': 'Reserva creada.', 'data': nueva}, 201);
    }
    if (RegExp(r'^/api/reservas/\d+$').hasMatch(ruta) && (peticion.method == 'PUT' || peticion.method == 'DELETE')) {
      return json({'success': true, 'message': 'OK', 'data': null});
    }
    if (ruta == '/api/agenda' && peticion.method == 'GET') {
      return json({'success': true, 'code': 'SCHEDULE_RETRIEVED', 'message': 'OK', 'data': horarios});
    }
    if (ruta == '/api/liquidaciones-comisiones' && peticion.method == 'GET') {
      return json({'success': true, 'code': 'SETTLEMENTS_RETRIEVED', 'message': 'OK', 'data': liquidacionesGuardadas});
    }
    if (ruta == '/api/liquidaciones-comisiones' && peticion.method == 'POST') {
      final nueva = {
        'id': 500 + liquidacionesGuardadas.length,
        'totalFacturado': 300000,
        'totalComisiones': 90000,
        'cantidadServicios': 2,
        ...(jsonDecode(peticion.body) as Map<String, Object?>),
      };
      liquidacionesGuardadas.add(nueva);
      return json({'success': true, 'code': 'SETTLEMENT_CREATED', 'message': 'Liquidación creada.', 'data': nueva}, 201);
    }
    if (ruta == '/api/comisiones' && peticion.method == 'GET') {
      return json({'success': true, 'code': 'COMMISSIONS_RETRIEVED', 'message': 'OK', 'data': comisiones});
    }
    if (RegExp(r'^/api/comisiones/\d+/servicios$').hasMatch(ruta)) {
      return json({'success': true, 'message': 'OK', 'data': serviciosDeComision});
    }
    return json({'success': false, 'message': 'No encontrado'}, 404);
  });
}
