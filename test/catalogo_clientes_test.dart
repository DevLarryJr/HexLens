import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_clientes.dart';
import 'package:proyecto_movil/models/cliente.dart';
import 'package:proyecto_movil/screens/catalogo_clientes_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('Iniciales del cliente', () {
    Cliente c(String n) =>
        Cliente(nombre: n, documento: '', telefono: '', email: '', estado: EstadoCliente.realizada, detalle: '');
    expect(c('Andrés Molina').iniciales, 'AM');
    expect(c('daniel castro ruiz').iniciales, 'DC');
    expect(c('Ana').iniciales, 'A');
  });

  testWidgets('Clientes: detalle desde la agenda, filtros y búsqueda', (t) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    String? sinResultados;
    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: CatalogoClientesScreen(onSinResultados: (q) => sinResultados = q),
    ));

    expect(find.text('Todos (4)'), findsOneWidget);
    expect(find.text('Sesión familiar · 15 Oct, 11:30 Set Principal'), findsOneWidget);
    expect(find.text('AM'), findsOneWidget);

    await t.tap(find.text('★ Frecuentes'));
    await t.pump();
    expect(find.text('Valentina Ruiz'), findsOneWidget);
    expect(find.text('Daniel Castro'), findsNothing);

    await t.tap(find.text('Todos (4)'));
    await t.enterText(find.byType(TextField), '315 889');
    await t.pump();
    expect(find.text('Daniel Castro'), findsOneWidget);
    expect(find.text('Valentina Ruiz'), findsNothing);

    await t.enterText(find.byType(TextField), 'Lucía');
    await t.testTextInput.receiveAction(TextInputAction.search);
    await t.pump();
    expect(sinResultados, 'Lucía');

    // Un cliente registrado con la pantalla abierta aparece de inmediato, sin tildes en la búsqueda.
    registrarCliente(
      tipoDocumento: 'C.C.',
      documento: '1020777888',
      nombres: 'Lucía',
      apellidos: 'Gómez',
      telefono: '300 111 2233',
    );
    await t.pump();
    expect(find.text('Lucía Gómez'), findsOneWidget);
    expect(find.text('CLIENTE NUEVO'), findsOneWidget);

    await t.enterText(find.byType(TextField), '');
    await t.pump();
    expect(find.text('Todos (5)'), findsOneWidget);
  });
}
