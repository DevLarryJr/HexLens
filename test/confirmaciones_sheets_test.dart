import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_agenda.dart';
import 'package:proyecto_movil/screens/confirmaciones_sheets.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t, Future<Object?> Function(BuildContext) mostrar, void Function(Object?) resultado) async {
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
      home: Builder(
        builder: (c) => Scaffold(
          body: TextButton(onPressed: () async => resultado(await mostrar(c)), child: const Text('abrir')),
        ),
      ),
    ));
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
  }

  testWidgets('Cancelación: muestra la sesión real y devuelve el motivo elegido', (t) async {
    Object? motivo = 'sin respuesta';
    await abrir(t, showCancelarCitaSheet, (r) => motivo = r);

    expect(find.text('C.C. 1.025.340.890'), findsOneWidget);
    expect(find.text('Jueves 15 Octubre 2026 • 10:00 AM'), findsOneWidget);
    expect(find.text('Ciclorama Blanco'), findsOneWidget);

    await t.tap(find.text('Inasistencia del cliente / No-Show'));
    await t.pump();
    await t.tap(find.text('Confirmar Cancelación'));
    await t.pumpAndSettle();
    expect(motivo, 'Inasistencia del cliente / No-Show');
  });

  testWidgets('Cancelación: cerrar sin confirmar devuelve null / false', (t) async {
    Object? r = 'sin respuesta';
    await abrir(t, showConfirmarCancelacionSheet, (v) => r = v);
    await t.tap(find.text('Volver'));
    await t.pumpAndSettle();
    expect(r, false);
  });

  testWidgets('Atendido: comisión del fotógrafo y checklist obligatorio', (t) async {
    Object? ok;
    await abrir(t, (c) => showConfirmarAtendidoSheet(c, sesion: sesionEnGestion), (r) => ok = r);
    expect(find.text('Comisión: 30% (\$36.000)'), findsOneWidget);
    expect(find.text('Duración: 45 min'), findsOneWidget);

    // Desmarcar un punto obligatorio bloquea la confirmación.
    await t.tap(find.text('Backup de memoria transferido'));
    await t.pump();
    expect(find.text('Completa los tres primeros puntos del checklist para confirmar.'), findsOneWidget);
    await t.tap(find.text('Confirmar Atendido'));
    await t.pump();
    expect(ok, isNull);

    await t.tap(find.text('Backup de memoria transferido'));
    await t.pump();
    await t.tap(find.text('Confirmar Atendido'));
    await t.pumpAndSettle();
    expect(ok, true);
  });
}
