import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/cierres_periodo_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/widgets/cierres/cierre_cards.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const CierresPeriodoScreen(),
    ));
  }

  testWidgets('Cierres: el resumen suma los cierres visibles', (t) async {
    await abrir(t);
    expect(find.text('2 registros'), findsOneWidget);
    expect(find.textContaining('\$3.050.000', findRichText: true), findsOneWidget);
    expect(find.text('\$988.000'), findsOneWidget);
    expect(find.text('\$2.062.000'), findsOneWidget);
    expect(find.text('\$822.000'), findsOneWidget); // Estudio = Total − Staff de octubre
    expect(find.text('Quincena 1 • 01 Oct 2026 - 15 Oct 2026'), findsOneWidget);
    expect(find.text('Laura M., Mateo R., Sara T.'), findsOneWidget);
  });

  testWidgets('Cierres: los filtros de mes filtran de verdad', (t) async {
    await abrir(t);
    await t.tap(find.text('Octubre'));
    await t.pump();
    expect(find.byType(CierreCard), findsOneWidget);
    expect(find.text('1 registro'), findsOneWidget);
    expect(find.textContaining('\$1.200.000', findRichText: true), findsNWidgets(2)); // resumen y tarjeta

    // Los meses del filtro salen de los cierres que existen (sin meses vacíos fijos).
    expect(find.text('Agosto'), findsNothing);
    await t.tap(find.text('Septiembre'));
    await t.pump();
    expect(find.byType(CierreCard), findsOneWidget);
    expect(find.text('1 registro'), findsOneWidget);
    expect(find.text('Quincena 2 • 16 Sep 2026 - 30 Sep 2026'), findsOneWidget);
  });
}
