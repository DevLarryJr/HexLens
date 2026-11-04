import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/nueva_especialidad_sheet.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Nueva especialidad: rechaza nombres existentes y devuelve el nuevo', (t) async {
    t.view.physicalSize = const Size(1600, 4000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    String? resultado;
    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () async => resultado = await showNuevaEspecialidadSheet(context),
            child: const Text('abrir'),
          ),
        ),
      ),
    ));
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();

    await t.enterText(find.byType(TextField), 'retratos');
    await t.pump();
    expect(find.text('Ya existe la especialidad Retratos.'), findsOneWidget);
    await t.tap(find.text('Guardar Especialidad'));
    await t.pumpAndSettle();
    expect(resultado, isNull);

    await t.enterText(find.byType(TextField), 'Moda & Pasarela');
    await t.pump();
    await t.tap(find.text('Guardar Especialidad'));
    await t.pumpAndSettle();
    expect(resultado, 'Moda & Pasarela');
  });
}
