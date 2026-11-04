import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_servicios.dart';
import 'package:proyecto_movil/screens/nueva_reserva_fecha_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/utils/formato.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('Rangos de hora en formato de 12 h', () {
    DateTime h(int hora, [int min = 0]) => DateTime(2026, 10, 15, hora, min);
    expect(rangoAmPm(h(10), h(10, 45)), '10:00 - 10:45 AM');
    expect(rangoAmPm(h(14, 15), h(15)), '02:15 - 03:00 PM');
    expect(rangoAmPm(h(11, 30), h(12, 15)), '11:30 AM - 12:15 PM');
    expect(horaAmPm(h(12)), '12:00 PM');
    expect(horaAmPm(h(0, 5)), '12:05 AM');
    expect(diaCorto(h(9)), 'JUE');
  });

  Future<void> abrir(WidgetTester t, {int servicio = 0}) async {
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
      home: NuevaReservaFechaScreen(servicio: serviciosReserva[servicio]),
    ));
  }

  testWidgets('Fecha: tarifa, duración y bloques salen del servicio elegido', (t) async {
    await abrir(t);
    expect(find.text('\$120.000 COP'), findsOneWidget);
    expect(find.text('RETRATO PROFESIONAL (45M)'), findsOneWidget);
    expect(find.text('5 Libres'), findsOneWidget);
    expect(find.text('Jueves, 15 Oct • 10:00 AM'), findsOneWidget);
    expect(find.text('02:15 - 03:00 PM'), findsOneWidget);

    // Otro servicio: cambian tarifa, duración y fin de los bloques libres.
    await abrir(t, servicio: 4); // Fotografía de producto, 120 min, $280.000
    expect(find.text('\$280.000 COP'), findsOneWidget);
    expect(find.text('120\nMIN'), findsOneWidget);
    expect(find.text('10:00 AM - 12:00 PM'), findsOneWidget);
  });

  testWidgets('Fecha: al cambiar de día se eligen sus bloques y el primero libre', (t) async {
    await abrir(t);
    await t.tap(find.text('17'));
    await t.pump();
    expect(find.text('Horarios para Sábado 17'), findsOneWidget);
    expect(find.text('Sesión Daniel Castro'), findsNothing);
    expect(find.text('Sábado, 17 Oct • 10:30 AM'), findsOneWidget);

    // El día pasado no se puede elegir.
    await t.tap(find.text('14'));
    await t.pump();
    expect(find.text('Horarios para Sábado 17'), findsOneWidget);
  });

  testWidgets('Fecha: las flechas recorren los días y el domingo sale cerrado', (t) async {
    final semantica = t.ensureSemantics();
    await abrir(t);
    // Al abrir no se puede retroceder más allá de ayer.
    await t.tap(find.bySemanticsLabel('Días anteriores'));
    await t.pump();
    expect(find.text('14'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Días siguientes'));
    await t.pump();
    expect(find.text('14'), findsNothing);
    expect(find.text('Cerrado'), findsOneWidget); // domingo 18
    await t.tap(find.text('18'));
    await t.pump();
    expect(find.text('Horarios para Jueves 15'), findsOneWidget); // no cambia

    await t.tap(find.text('19'));
    await t.pump();
    expect(find.text('Horarios para Lunes 19'), findsOneWidget);
    semantica.dispose();
  });

  testWidgets('Fecha: el calendario permite elegir cualquier fecha futura', (t) async {
    final semantica = t.ensureSemantics();
    await abrir(t);
    await t.tap(find.bySemanticsLabel('Abrir calendario'));
    await t.pumpAndSettle();
    expect(find.text('Fecha de la sesión'), findsOneWidget);
    await t.tap(find.text('30'));
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();

    expect(find.text('Horarios para Viernes 30'), findsOneWidget);
    expect(find.text('Viernes, 30 Oct • 09:00 AM'), findsOneWidget);
    semantica.dispose();
  });
}
