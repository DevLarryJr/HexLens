import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:proyecto_movil/main.dart';
import 'package:proyecto_movil/screens/agenda_screen.dart';
import 'package:proyecto_movil/screens/busqueda_global_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

import 'api_falsa.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Login navega al inicio administrativo', (tester) async {
    usarApiFalsa();
    await tester.pumpWidget(const MyApp(showSplash: false));
    expect(find.text('Acceso al estudio'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, usuarioPrueba);
    await tester.enterText(find.byType(TextField).last, clavePrueba);
    await tester.ensureVisible(find.text('Iniciar sesión'));
    await tester.tap(find.text('Iniciar sesión'));
    await tester.pumpAndSettle();

    expect(find.text('Próximas reservas de hoy'), findsOneWidget);
  });

  testWidgets('Barra inferior abre la agenda', (tester) async {
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const HomeShell()));
    await tester.tap(find.text('Agenda').last);
    await tester.pumpAndSettle();
    expect(find.byType(AgendaScreen), findsOneWidget);
    expect(find.text('Cierre Operativo Proyectado'), findsOneWidget);
  });

  testWidgets('Menú "Más" lista las opciones y abre la elegida', (tester) async {
    tester.view.physicalSize = const Size(1600, 4000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const HomeShell()));
    await tester.tap(find.text('Más').last);
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNWidgets(8));
    expect(find.text('Cerrar sesión'), findsOneWidget);

    await tester.tap(find.text('Búsqueda Global'));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsNothing);
    expect(find.byType(BusquedaGlobalScreen), findsOneWidget);
  });
}
