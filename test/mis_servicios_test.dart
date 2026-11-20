import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/mis_servicios_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const MisServiciosScreen(),
    ));
  }

  testWidgets('Mis servicios: contadores, comisión y próxima sesión salen de los datos', (t) async {
    await abrir(t);
    expect(find.text('Todos (3)'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Próxima sesión: Hoy 10:00 AM'), findsOneWidget);
    expect(find.text('\$36.000 COP'), findsOneWidget);
    expect(find.text('\$45.000 COP'), findsOneWidget);
    expect(find.text('08 Oct 2026'), findsOneWidget);
  });

  testWidgets('Mis servicios: filtros y búsqueda, con aviso si no hay resultados', (t) async {
    await abrir(t);
    await t.tap(find.text('Graduación'));
    await t.pump();
    expect(find.text('Daniel Castro'), findsOneWidget);
    expect(find.text('Elena Gómez'), findsNothing);

    await t.tap(find.text('Todos (3)'));
    await t.enterText(find.byType(TextField), 'RSV-2026-029');
    await t.pump();
    expect(find.text('Elena Gómez'), findsOneWidget);
    expect(find.text('Daniel Castro'), findsNothing);

    await t.enterText(find.byType(TextField), 'zzz');
    await t.pump();
    expect(find.text('Ningún servicio coincide con la búsqueda.'), findsOneWidget);
  });
}
