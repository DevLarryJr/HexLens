import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_cierres.dart';
import 'package:proyecto_movil/screens/nuevo_cierre_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('Liquidación: Sara cobra el 30 % de su base y el cierre 10A cuadra', () {
    final sara = liquidacionesUltimoCierre.firstWhere((l) => l.fotografo.nombre == 'Sara Torres');
    expect(sara.base, 320000);
    expect(sara.comision, 96000);
    final c = cierres.first;
    expect((c.total, c.staff, c.estudio, c.servicios), (1200000, 378000, 822000, 8));
  });

  test('codigoCierre y liquidacionesEntre', () {
    expect(codigoCierre(DateTime(2026, 10, 1)), '#CIE-2026-10A');
    expect(codigoCierre(DateTime(2026, 10, 16)), '#CIE-2026-10B');
    final semana = liquidacionesEntre(DateTime(2026, 10, 1), DateTime(2026, 10, 5));
    expect(semana.map((l) => l.fotografo.nombre), ['Laura Méndez', 'Sara Torres']);
    expect(semana.first.sesiones.single.cliente, 'Carlos Mendoza');
  });

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
      home: const Scaffold(body: NuevoCierreScreen()),
    ));
  }

  testWidgets('Nuevo cierre: desglose calculado y aviso de cierre existente', (t) async {
    await abrir(t);
    expect(find.text('- \$378.000'), findsOneWidget);
    expect(find.text('\$822.000'), findsOneWidget);
    expect(find.text('\$96.000'), findsOneWidget);
    expect(find.text('FOTÓGRAFOS (3)'), findsOneWidget);
    expect(find.text('\$36.000 COP'), findsOneWidget);

    await t.tap(find.text('Confirmar y Generar Cierre Contable'));
    await t.pump();
    expect(find.text('El período #CIE-2026-10A ya tiene cierre'), findsOneWidget);
  });
}
