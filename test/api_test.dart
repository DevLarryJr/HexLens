import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:proyecto_movil/api/api.dart';
import 'package:proyecto_movil/data/mock_clientes.dart';
import 'package:proyecto_movil/models/cliente.dart';
import 'package:proyecto_movil/utils/formato.dart';

import 'api_falsa.dart';

void main() {
  tearDown(Api.cerrarSesion);

  test('El token se lee: rol, empresa y vencimiento', () {
    final sesion = SesionApi.desdeToken(tokenFalso());
    expect(sesion.rol, 'Gestor');
    expect(sesion.esGestor, isTrue);
    expect(sesion.empresaId, '6');
    expect(sesion.empresa, 'Hex Lens');
    expect(sesion.usuario, usuarioPrueba);
    expect(sesion.vence, DateTime.fromMillisecondsSinceEpoch(1893456000 * 1000));
    expect(SesionApi.desdeToken(tokenFalso(rol: 'Profesional')).esGestor, isFalse);
  });

  test('Login: envía Usuario y Clave a /api/sesion y guarda el token', () async {
    usarApiFalsa();
    await expectLater(Api.iniciarSesion(usuarioPrueba, 'mala'),
        throwsA(isA<ApiError>().having((e) => e.mensaje, 'mensaje', 'Usuario o clave incorrectos.')));
    expect(Api.conectada, isFalse);

    await Api.iniciarSesion(' $usuarioPrueba ', clavePrueba);
    expect(Api.conectada, isTrue);
    final login = peticionesRecibidas.last;
    expect(login.url.toString(), '$urlApi/api/sesion');
    expect(jsonDecode(login.body), {'Usuario': usuarioPrueba, 'Clave': clavePrueba});
  });

  test('Clientes: el directorio se llena con los de la API (campos en PascalCase o camelCase)', () async {
    usarApiFalsa(clientes: [
      {'id': 1, 'documento': '1098765432', 'nombres': 'Larry', 'apellidos': 'Sánchez', 'celular': '3001234567', 'correo': 'l@x.co'},
      {'Id': 2, 'Documento': '52890123', 'Nombres': 'Ana', 'Apellidos': 'Ruiz', 'Celular': '3001112233'},
    ]);
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    await sincronizarClientes();

    expect(clientes.map((c) => c.nombre), ['Larry Sánchez', 'Ana Ruiz']);
    final larry = clientes.first;
    expect(larry.id, 1);
    expect(larry.documento, 'C.C. 1.098.765.432');
    expect(larry.telefono, '+57 300 123 4567');
    expect(larry.email, 'l@x.co');
    expect(clientes.last.id, 2);
    expect(peticionesRecibidas.last.headers['Authorization'], 'Bearer ${tokenFalso()}');
  });

  test('Registrar cliente con sesión: POST /api/clientes con el formato de la API', () async {
    usarApiFalsa();
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    final cliente = await guardarCliente(
      tipoDocumento: 'C.C.',
      documento: '1.020.777.888',
      nombres: ' Lucía ',
      apellidos: 'Gómez',
      telefono: '300 111 2233',
      email: 'lucia@correo.com',
      nacimiento: DateTime(1995, 5, 22),
    );
    expect(jsonDecode(peticionesRecibidas.last.body), {
      'Documento': '1020777888',
      'Nombres': 'Lucía',
      'Apellidos': 'Gómez',
      'Celular': '3001112233',
      'Correo': 'lucia@correo.com',
      'FechaNacimiento': '1995-05-22',
    });
    expect(cliente.id, 1);
    expect(cliente.nombre, 'Lucía Gómez');
    expect(clientes.first, same(cliente));
    expect(cliente.estado, EstadoCliente.nuevo);
  });

  test('Registrar cliente: si la API ya tiene ese documento (GET /api/clientes/{doc}) no se crea otro', () async {
    usarApiFalsa(clientes: [
      {'id': 9, 'documento': '1020777888', 'nombres': 'Lucía', 'apellidos': 'Gómez', 'celular': '3001112233'},
    ]);
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    await expectLater(
      guardarCliente(tipoDocumento: 'C.C.', documento: '1.020.777.888', nombres: 'Otra', apellidos: 'Persona', telefono: '3000000000'),
      throwsA(isA<ApiError>().having((e) => e.mensaje, 'mensaje', contains('Lucía Gómez'))),
    );
    expect(peticionesRecibidas.last.url.path, '/api/clientes/1020777888');
    expect(peticionesRecibidas.where((p) => p.method == 'POST' && p.url.path == '/api/clientes'), isEmpty);
  });

  test('Token vencido (401): se cierra la sesión y el error lo dice', () async {
    usarApiFalsa();
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    Api.cliente = MockClient((_) async => http.Response('{"success":false}', 401));
    await expectLater(
        Api.get('/api/clientes'),
        throwsA(isA<ApiError>()
            .having((e) => e.sesionVencida, 'sesionVencida', isTrue)
            .having((e) => e.mensaje, 'mensaje', 'Tu sesión venció. Vuelve a iniciar sesión.')));
    expect(Api.conectada, isFalse);
  });

  test('Sin internet: mensaje claro', () async {
    Api.cliente = MockClient((_) async => throw http.ClientException('sin red'));
    await expectLater(Api.iniciarSesion(usuarioPrueba, clavePrueba),
        throwsA(isA<ApiError>().having((e) => e.estado, 'estado', isNull)));
  });

  test('fechaDesdeNumerica', () {
    expect(fechaDesdeNumerica('22/05/1995'), DateTime(1995, 5, 22));
    expect(fechaDesdeNumerica('31/02/2000'), isNull);
    expect(fechaDesdeNumerica('dd/mm/aaaa'), isNull);
  });
}
