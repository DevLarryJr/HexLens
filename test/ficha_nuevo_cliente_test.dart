import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/ficha_nuevo_cliente_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

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
      home: const FichaNuevoClienteScreen(),
    ));
  }

  testWidgets('Ficha: avisa si la cédula ya existe y no registra', (t) async {
    await abrir(t);
    expect(find.text('dd/mm/aaaa'), findsOneWidget);

    await t.enterText(find.byType(TextField).first, '1025340890');
    await t.pump();
    expect(find.text('Ya existe un cliente con ese documento (Valentina Ruiz)'), findsOneWidget);

    await t.tap(find.text('Confirmar Registro'));
    await t.pump();
    expect(find.text('Ya existe un cliente con ese documento (Valentina Ruiz)'), findsNWidgets(2));
  });

  testWidgets('Ficha: la fecha de nacimiento queda en formato dd/mm/aaaa', (t) async {
    await abrir(t);
    await t.tap(find.text('dd/mm/aaaa'));
    await t.pumpAndSettle();
    await t.tap(find.text('15'));
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();
    expect(find.text('15/01/1995'), findsOneWidget);
  });
}
