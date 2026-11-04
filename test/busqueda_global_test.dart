import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/busqueda_global_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/widgets/busqueda/busqueda_widgets.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t, String inicial) async {
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
      home: BusquedaGlobalScreen(inicial: inicial),
    ));
  }

  testWidgets('Búsqueda: sin resultados para "Carlos Pérez"', (t) async {
    await abrir(t, 'Carlos Pérez');
    expect(find.byType(SinResultados), findsOneWidget);
    expect(find.text('0 coincidencias'), findsOneWidget);
  });

  testWidgets('Búsqueda: la cédula sin puntos encuentra al cliente', (t) async {
    await abrir(t, '1025340890');
    expect(find.text('Valentina Ruiz'), findsOneWidget);
    expect(find.text('1 coincidencia'), findsOneWidget);

    await t.enterText(find.byType(TextField), 'C.C. 52.890');
    await t.pump();
    expect(find.text('Laura Méndez'), findsOneWidget);
  });

  testWidgets('Búsqueda: índice desde los modelos (servicios del catálogo unificado, sin tildes)', (t) async {
    await abrir(t, 'retrato');
    expect(find.byType(ResultadoBusquedaCard), findsNWidgets(3));
    expect(find.text('#SRV-007 • \$160.000'), findsOneWidget);

    await t.enterText(find.byType(TextField), 'nicolas');
    await t.pump();
    expect(find.text('Editorial • C.C. 79.991.234'), findsOneWidget);
  });
}
