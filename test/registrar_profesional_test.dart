import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/registrar_profesional_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 6000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const RegistrarProfesionalScreen(),
    ));
  }

  testWidgets('Profesional: la simulación usa el servicio base de la especialidad', (t) async {
    await abrir(t);
    expect(find.text('En una sesión de \$120.000 COP:'), findsOneWidget);
    expect(find.text('\$36.000 COP'), findsOneWidget);

    await t.tap(find.text('Retratos'));
    await t.pumpAndSettle();
    await t.tap(find.text('Familiar').last);
    await t.pumpAndSettle();
    expect(find.text('En una sesión de \$180.000 COP:'), findsOneWidget);
    expect(find.text('\$54.000 COP'), findsOneWidget);
    expect(find.text('\$126.000 COP'), findsOneWidget);
  });
}
