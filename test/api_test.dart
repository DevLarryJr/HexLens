import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:proyecto_movil/data/mock_clientes.dart';
import 'package:proyecto_movil/models/cliente.dart';
import 'package:proyecto_movil/services/remote/clientes_api.dart';
import 'package:proyecto_movil/utils/formato.dart';

import 'api_falsa.dart';

void main() {
  tearDown(SesionActual.cerrar);

  test('El token se lee: rol, empresa y vencimiento', () {
    final sesion = LoginResponse.desdeToken(tokenFalso());
    expect(sesion.rol, 'Gestor');
    expect(sesion.esGestor, isTrue);
    expect(sesion.empresaId, '6');
    expect(sesion.empresa, 'Hex Lens');
    expect(sesion.usuario, usuarioPrueba);
    expect(sesion.vence, DateTime.fromMillisecondsSinceEpoch(1893456000 * 1000));
    expect(LoginResponse.desdeToken(tokenFalso(rol: 'Profesional')).esGestor, isFalse);
  });

  test('Login: envía Usuario y Clave a /api/sesion y guarda el token', () async {
    usarApiFalsa();
    await expectLater(iniciarSesion(usuarioPrueba, 'mala'),
        throwsA(isA<ApiException>().having((e) => e.message, 'message', 'Usuario o clave incorrectos.')));
    expect(SesionActual.conectada, isFalse);

    await iniciarSesion(' $usuarioPrueba ', clavePrueba);
    expect(SesionActual.conectada, isTrue);
    final login = peticionesRecibidas.last;
    expect(login.url.toString(), '${AppConfig.apiBaseUrl}/sesion');
    expect(jsonDecode(login.body), {'Usuario': usuarioPrueba, 'Clave': clavePrueba});
  });

  test('Clientes: el directorio se llena con los de la API (campos en PascalCase o camelCase)', () async {
    usarApiFalsa(clientes: [
      {'id': 1, 'documento': '1098765432', 'nombres': 'Larry', 'apellidos': 'Sánchez', 'celular': '3001234567', 'correo': 'l@x.co'},
      {'Id': 2, 'Documento': '52890123', 'Nombres': 'Ana', 'Apellidos': 'Ruiz', 'Celular': '3001112233'},
    ]);
    await iniciarSesion(usuarioPrueba, clavePrueba);
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
    await iniciarSesion(usuarioPrueba, clavePrueba);
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
    await iniciarSesion(usuarioPrueba, clavePrueba);
    await expectLater(
      guardarCliente(tipoDocumento: 'C.C.', documento: '1.020.777.888', nombres: 'Otra', apellidos: 'Persona', telefono: '3000000000'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', contains('Lucía Gómez'))),
    );
    expect(peticionesRecibidas.last.url.path, '/api/clientes/1020777888');
    expect(peticionesRecibidas.where((p) => p.method == 'POST' && p.url.path == '/api/clientes'), isEmpty);
  });

  test('Token vencido (401): se cierra la sesión y el error lo dice', () async {
    usarApiFalsa();
    await iniciarSesion(usuarioPrueba, clavePrueba);
    ApiService.clientePorDefecto = MockClient((_) async => http.Response('{"success":false}', 401));
    await expectLater(
      ClientesApi().listar(),
      throwsA(isA<ApiException>()
          .having((e) => e.isUnauthorized, 'isUnauthorized', isTrue)
          .having((e) => e.message, 'message', 'Tu sesión venció. Vuelve a iniciar sesión.')),
    );
    expect(SesionActual.conectada, isFalse);
    await expectLater(
        sincronizarClientes(), completes, reason: 'sin sesión, el directorio no consulta la API');
  });

  test('Sin internet: mensaje claro', () async {
    ApiService.clientePorDefecto = MockClient((_) async => throw http.ClientException('sin red'));
    await expectLater(iniciarSesion(usuarioPrueba, clavePrueba),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', isNull)));
  });

  test('fechaDesdeNumerica', () {
    expect(fechaDesdeNumerica('22/05/1995'), DateTime(1995, 5, 22));
    expect(fechaDesdeNumerica('31/02/2000'), isNull);
    expect(fechaDesdeNumerica('dd/mm/aaaa'), isNull);
  });
}
