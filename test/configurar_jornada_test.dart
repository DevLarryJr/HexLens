import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/configurar_jornada_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const ConfigurarJornadaScreen(),
    ));
  }

  testWidgets('Jornada: arranca en el día de hoy (jueves en las pruebas) con horas de 12 h', (t) async {
    await abrir(t);
    expect(find.text('EDICIÓN DÍA\nJUEVES'), findsOneWidget);
    expect(find.text('08:00 AM'), findsOneWidget);
    expect(find.text('05:00 PM'), findsOneWidget);
    expect(find.text('01:00 PM'), findsOneWidget);
    expect(find.text('02:00 PM'), findsOneWidget);
    expect(find.text('Lun'), findsOneWidget);
    expect(find.text('0 conflictos con 2 reservas programadas de esta semana.'), findsOneWidget);
  });

  testWidgets('Jornada: el sábado carga 09–14 sin almuerzo y el jueves conserva lo editado', (t) async {
    await abrir(t);
    await t.tap(find.byIcon(Icons.keyboard_arrow_up).first);
    await t.pump();
    expect(find.text('08:30 AM'), findsOneWidget);

    await t.tap(find.text('Sáb'));
    await t.pump();
    expect(find.text('EDICIÓN DÍA\nSÁBADO'), findsOneWidget);
    expect(find.text('09:00 AM'), findsOneWidget);
    expect(find.text('02:00 PM'), findsOneWidget);
    expect(find.text('Inicio de almuerzo'), findsNothing);
    expect(find.text('Jue'), findsOneWidget);

    await t.tap(find.text('Jue'));
    await t.pump();
    expect(find.text('08:30 AM'), findsOneWidget);
  });

  testWidgets('Jornada: detecta el conflicto si el turno empieza después de la reserva', (t) async {
    await abrir(t);
    for (var i = 0; i < 5; i++) {
      await t.tap(find.byIcon(Icons.keyboard_arrow_up).first);
      await t.pump();
    }
    expect(find.text('10:30 AM'), findsOneWidget);
    expect(find.text('2 conflictos con 2 reservas programadas de esta semana.'), findsOneWidget);
  });

  testWidgets('Jornada: se puede programar las semanas siguientes, no las pasadas', (t) async {
    await abrir(t);
    expect(find.text('Semana 42 · 12–18 Oct (actual)'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Semana anterior'));
    await t.pump();
    expect(find.text('Semana 42 · 12–18 Oct (actual)'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Semana siguiente'));
    await t.pump();
    expect(find.text('Semana 43 · 19–25 Oct'), findsOneWidget);
    expect(find.text('EDICIÓN DÍA\nLUNES'), findsOneWidget);
    expect(find.textContaining('reservas programadas de esta semana.'), findsOneWidget);
  });
}
