import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_clientes.dart';
import 'package:proyecto_movil/data/mock_fotografos.dart';
import 'package:proyecto_movil/data/mock_servicios.dart';
import 'package:proyecto_movil/screens/nueva_reserva_confirmacion_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t, Widget pantalla) async {
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
      home: pantalla,
    ));
  }

  testWidgets('Confirmación: por defecto muestra la reserva de ejemplo desde los modelos', (t) async {
    await abrir(t, const NuevaReservaConfirmacionScreen());
    expect(find.text('\$120.000 '), findsNothing); // va en un TextSpan
    expect(find.textContaining('120.000'), findsOneWidget);
    expect(find.text('VR'), findsOneWidget);
    expect(find.text('C.C. 1.025.340.890 (Bogotá D.C.)'), findsOneWidget);
    expect(find.text('Jue, 15 Oct 2026'), findsOneWidget);
    expect(find.text('10:00 - 10:45 AM'), findsOneWidget);
    expect(find.text('Comisión: 30%'), findsOneWidget);
  });

  testWidgets('Confirmación: refleja otro cliente, servicio y fotógrafo', (t) async {
    await abrir(
      t,
      NuevaReservaConfirmacionScreen(
        cliente: clientes[1], // Andrés Molina
        servicio: serviciosReserva[3], // Sesión familiar, 90 min, $220.000
        fotografo: fotografos[1], // Mateo Ríos, 35 %
        inicio: DateTime(2026, 10, 16, 11, 30),
        lugar: 'Set Principal',
      ),
    );
    expect(find.text('AM'), findsOneWidget);
    expect(find.text('C.C. 1.018.992.114'), findsOneWidget);
    expect(find.text('FAMILIAR'), findsOneWidget);
    expect(find.text('Set Principal • 90 min'), findsOneWidget);
    expect(find.text('Vie, 16 Oct 2026'), findsOneWidget);
    expect(find.text('11:30 AM - 01:00 PM'), findsOneWidget);
    expect(find.text('Comisión: 35%'), findsOneWidget);
    expect(find.textContaining('220.000'), findsOneWidget);
  });
}
