import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/api/api.dart';
import 'package:proyecto_movil/screens/login_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

import 'api_falsa.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<List<bool>> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 4000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    final logins = <bool>[];
    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: LoginScreen(onLogin: logins.add),
    ));
    return logins;
  }

  testWidgets('Login: no entra sin contraseña y sí con ella', (t) async {
    final logins = await abrir(t);
    expect(find.text('3 Sesiones Activas'), findsOneWidget);

    await t.tap(find.text('Iniciar sesión'));
    await t.pump();
    expect(logins, isEmpty);
    expect(find.text('Ingresa tu usuario y contraseña'), findsOneWidget);

    // Clave equivocada: la API responde 401 y no entra.
    usarApiFalsa();
    await t.enterText(find.byType(TextField).first, usuarioPrueba);
    await t.enterText(find.byType(TextField).last, 'otra-clave');
    await t.tap(find.text('Iniciar sesión'));
    await t.pumpAndSettle();
    expect(logins, isEmpty);
    expect(find.text('Usuario o clave incorrectos.'), findsOneWidget);

    // Clave correcta: entra con el rol que dice la API (Gestor → panel administrativo), aunque el
    // selector diga Fotógrafo.
    await t.enterText(find.byType(TextField).last, clavePrueba);
    await t.tap(find.text('Fotógrafo'));
    await t.tap(find.text('Iniciar sesión'));
    await t.pumpAndSettle();
    expect(logins, [true]);
    expect(Api.sesion?.empresa, 'Hex Lens');
  });
}
