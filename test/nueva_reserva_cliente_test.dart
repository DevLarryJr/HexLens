import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_clientes.dart';
import 'package:proyecto_movil/screens/nueva_reserva_cliente_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/widgets/reserva/cliente_seleccion.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('Cliente.coincide: nombre sin tildes, cédula y teléfono', () {
    final andres = clientePorNombre('Andrés Molina')!;
    expect(andres.coincide('andres'), isTrue);
    expect(andres.coincide('MOLINA'), isTrue);
    expect(andres.coincide('1.018.992'), isTrue);
    expect(andres.coincide('301 456'), isTrue);
    expect(andres.coincide('valentina'), isFalse);
    expect(andres.coincide('  '), isTrue);
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
      home: const NuevaReservaClienteScreen(),
    ));
  }

  testWidgets('Cliente: arranca vacío con todos los clientes y Valentina elegida', (t) async {
    await abrir(t);
    expect(find.byType(ClienteResultadoCard), findsNWidgets(clientes.length));
    expect(find.text('${clientes.length}'), findsOneWidget);
    expect(find.text('Recurrente (3 sesiones)'), findsOneWidget);
    expect(find.textContaining('Al validar a Valentina Ruiz'), findsOneWidget);
  });

  testWidgets('Cliente: el buscador filtra y la selección cambia el resumen', (t) async {
    await abrir(t);
    await t.enterText(find.byType(TextField), 'perez');
    await t.pump();
    expect(find.byType(ClienteResultadoCard), findsOneWidget);
    expect(find.text('Camila Pérez'), findsOneWidget);

    await t.tap(find.text('Camila Pérez'));
    await t.pump();
    expect(find.textContaining('Al validar a Camila Pérez'), findsOneWidget);

    await t.enterText(find.byType(TextField), 'zzz');
    await t.pump();
    expect(find.byType(ClienteResultadoCard), findsNothing);
    expect(find.text('Sin coincidencias. Registra al cliente como nuevo.'), findsOneWidget);
  });
}
