import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:proyecto_movil/config/api_paths.dart';
import 'package:proyecto_movil/main.dart';
import 'package:proyecto_movil/models/login/login_request.dart';
import 'package:proyecto_movil/services/local/secure_storage_service.dart';
import 'package:proyecto_movil/services/remote/clientes_api.dart';
import 'package:proyecto_movil/services/remote/login_service.dart';

import 'api_falsa.dart';

String tokenVencido() {
  String parte(Map<String, Object> datos) => base64Url.encode(utf8.encode(jsonEncode(datos))).replaceAll('=', '');
  return [
    parte({'alg': 'HS256', 'typ': 'JWT'}),
    parte({'usuario': usuarioPrueba, 'role': 'Gestor', 'exp': 946684800}),
    'firma',
  ].join('.');
}

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(SesionActual.cerrar);

  const storage = SecureStorageService();

  test('"Recordar sesión": el login guarda la sesión y se puede retomar al abrir la app', () async {
    usarApiFalsa();
    await iniciarSesion(usuarioPrueba, clavePrueba);

    final guardada = await storage.readSesion();
    expect(guardada?.accessToken, tokenFalso());
    expect(await storage.readToken(), tokenFalso());

    final retomada = await SesionActual.restaurar();
    expect(retomada?.accessToken, tokenFalso());
    expect(retomada?.esGestor, isTrue);
    expect(SesionActual.conectada, isTrue);
  });

  test('Sin "Recordar sesión" no queda nada guardado', () async {
    usarApiFalsa();
    await iniciarSesion(usuarioPrueba, clavePrueba);
    await LoginService().login(const LoginRequest(usuario: usuarioPrueba, clave: clavePrueba), recordar: false);

    expect(SesionActual.conectada, isTrue, reason: 'la sesión sigue abierta mientras la app está abierta');
    expect(await storage.readSesion(), isNull);
    expect(await storage.readToken(), isNull);
  });

  test('Una sesión guardada que ya venció no se retoma', () async {
    await storage.storage.write(
      key: SecureStorageService.sesionKey,
      value: jsonEncode({'accessToken': tokenVencido()}),
    );
    expect(await SesionActual.restaurar(), isNull);
    expect(SesionActual.conectada, isFalse);
    expect(await storage.storage.read(key: SecureStorageService.sesionKey), isNull, reason: 'se borra');
  });

  test('Cerrar sesión borra la sesión guardada', () async {
    usarApiFalsa();
    await iniciarSesion(usuarioPrueba, clavePrueba);
    await LoginService().logout();
    expect(await storage.readSesion(), isNull);
    expect(await SesionActual.restaurar(), isNull);
  });

  test('Sin sesión, los servicios no llaman a la API', () async {
    usarApiFalsa();
    await expectLater(ClientesApi().listar(), throwsA(isA<SessionException>()));
    expect(peticionesRecibidas, isEmpty);
  });

  test('Las rutas salen de ApiPaths y el token va en la cabecera', () async {
    usarApiFalsa(clientes: [
      {'id': 1, 'documento': '1098765432', 'nombres': 'Larry', 'apellidos': 'Sánchez', 'celular': '3001234567'},
    ]);
    await iniciarSesion(usuarioPrueba, clavePrueba);
    final cliente = await ClientesApi().consultar('1.098.765.432');
    expect(cliente?.nombre, 'Larry Sánchez');
    expect(peticionesRecibidas.last.url.toString(), '${AppConfig.apiBaseUrl}${ApiPaths.cliente('1098765432')}');
    expect(peticionesRecibidas.last.headers['Authorization'], 'Bearer ${tokenFalso()}');
    expect(await ClientesApi().consultar('999'), isNull, reason: '404 = no existe');
  });

  test('Errores de validación de la API (errors) se muestran juntos', () async {
    ApiService.clientePorDefecto = MockClient((_) async => http.Response(
          jsonEncode({
            'title': '',
            'errors': {
              'Nombre': ['El nombre es obligatorio.'],
              'Precio': ['El precio debe ser mayor a 0.'],
            },
          }),
          400,
        ));
    final api = ApiService(baseUrl: AppConfig.apiBaseUrl, enableLogs: false);
    await expectLater(
      api.post('/servicios', body: const {}),
      throwsA(isA<ApiException>()
          .having((e) => e.statusCode, 'statusCode', 400)
          .having((e) => e.message, 'message', 'El nombre es obligatorio. El precio debe ser mayor a 0.')),
    );
  });

  testWidgets('Con sesión guardada la app entra directo a su inicio, sin login', (tester) async {
    await tester.pumpWidget(MyApp(showSplash: false, sesionInicial: LoginResponse.desdeToken(tokenFalso())));
    expect(find.text('Acceso al estudio'), findsNothing);
    expect(find.byType(HomeShell), findsOneWidget);
  });
}
