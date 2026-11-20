import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_clientes.dart';
import 'package:proyecto_movil/models/cliente.dart';
import 'package:proyecto_movil/screens/registrar_cliente_sheet.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/utils/formato.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('clientePorDocumento y esCorreo', () {
    expect(clientePorDocumento('1025340890')?.nombre, 'Valentina Ruiz');
    expect(clientePorDocumento('C.C. 1.018.992.114')?.nombre, 'Andrés Molina');
    expect(clientePorDocumento('1.018.490.231'), isNull);
    expect(esCorreo('v.rojas@email.com'), isTrue);
    expect(esCorreo('v.rojas@email'), isFalse);
  });

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 6000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(onPressed: () => showRegistrarClienteSheet(context), child: const Text('abrir')),
        ),
      ),
    ));
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();
  }

  testWidgets('Registrar cliente: bloquea C.C. repetida y correo inválido; lo guarda en el directorio', (t) async {
    await abrir(t);
    final campos = find.byType(TextField);

    await t.enterText(campos.first, '1.025.340.890');
    await t.pump();
    expect(find.text('Ya existe un cliente con ese documento (Valentina Ruiz)'), findsOneWidget);
    await t.tap(find.text('Guardar Cliente'));
    await t.pump();
    expect(find.textContaining('registrado'), findsNothing);

    await t.enterText(campos.first, '1.018.490.231');
    await t.enterText(campos.last, 'v.rojas@email');
    await t.pump();
    expect(find.text('Ingresa un correo electrónico válido'), findsOneWidget);

    await t.enterText(campos.last, 'v.rojas@email.com');
    await t.pump();
    await t.tap(find.text('Guardar Cliente'));
    await t.pumpAndSettle();
    expect(find.text('Cliente Valentina Rojas Restrepo registrado'), findsOneWidget);

    final nuevo = clientePorDocumento('1018490231')!;
    expect(nuevo.nombre, 'Valentina Rojas Restrepo');
    expect(nuevo.documento, 'C.C. 1.018.490.231');
    expect(nuevo.telefono, '+57 314 892 4510');
    expect(nuevo.estado, EstadoCliente.nuevo);
    expect(clientes.first, same(nuevo));
  });
}
