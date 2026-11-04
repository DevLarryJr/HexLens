import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/agenda_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

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
      home: AgendaScreen(onNuevaReserva: () {}, onAbrirSesion: (_) {}),
    ));
  }

  testWidgets('Agenda: totales y contadores salen de las sesiones del día', (t) async {
    await abrir(t);
    expect(find.text('Jueves, 15 de Octubre 2026 • 5\nsesiones'), findsOneWidget);
    expect(find.text('Semana 42'), findsOneWidget);
    expect(find.text('Programadas (3)'), findsOneWidget);
    expect(find.text('\$700.000'), findsOneWidget);
    expect(find.text('4.25 h'), findsOneWidget);
    expect(find.text('15 OCT'), findsOneWidget);
  });

  testWidgets('Agenda: filtros de estado y staff filtran la lista', (t) async {
    await abrir(t);
    expect(find.text('Daniel Castro'), findsOneWidget);

    await t.tap(find.text('Programadas (3)'));
    await t.pump();
    expect(find.text('Daniel Castro'), findsNothing); // realizada
    expect(find.text('Andrés Molina'), findsOneWidget);

    await t.tap(find.text('Mateo R.'));
    await t.pump();
    expect(find.text('Andrés Molina'), findsOneWidget);
    expect(find.text('Valentina Ruiz'), findsNothing);

    // Tocar de nuevo el mismo fotógrafo quita el filtro de staff.
    await t.tap(find.text('Mateo R.'));
    await t.pump();
    expect(find.text('Valentina Ruiz'), findsOneWidget);

    await t.tap(find.text('Canceladas (1)'));
    await t.tap(find.text('Laura M.'));
    await t.pump();
    expect(find.text('Ninguna sesión coincide con los filtros.'), findsOneWidget);
  });

  testWidgets('Agenda: cambiar de día cambia título, lista y totales', (t) async {
    await abrir(t);
    await t.tap(find.text('17'));
    await t.pump();
    expect(find.text('Sábado, 17 de Octubre 2026 • 2\nsesiones'), findsOneWidget);
    expect(find.text('Familia Ortiz'), findsOneWidget);
    expect(find.text('Valentina Ruiz'), findsNothing);
    expect(find.text('\$670.000'), findsOneWidget);
    expect(find.text('4.5 h'), findsOneWidget);

    await t.tap(find.text('18')); // domingo: el estudio no atiende
    await t.pump();
    expect(find.text('Sin sesiones agendadas para este día.'), findsOneWidget);
    expect(find.text('\$0'), findsOneWidget);
  });

  testWidgets('Agenda: las flechas cambian de semana y "Volver a hoy" regresa', (t) async {
    await abrir(t);
    expect(find.text('Volver a hoy'), findsNothing);

    await t.tap(find.bySemanticsLabel('Semana siguiente'));
    await t.pump();
    expect(find.text('Semana 43'), findsOneWidget);
    expect(find.textContaining('Jueves, 22 de Octubre 2026'), findsOneWidget);

    // Muchas semanas hacia adelante: sigue habiendo datos (no solo la semana actual).
    for (var i = 0; i < 8; i++) {
      await t.tap(find.bySemanticsLabel('Semana siguiente'));
      await t.pump();
    }
    expect(find.text('Semana 51'), findsOneWidget);
    expect(find.text('Diciembre 2026'), findsOneWidget);

    await t.tap(find.text('Volver a hoy'));
    await t.pump();
    expect(find.textContaining('Jueves, 15 de Octubre 2026'), findsOneWidget);
    expect(find.text('Volver a hoy'), findsNothing);
  });

  testWidgets('Agenda: vista mensual con su calendario; tocar un día abre su agenda', (t) async {
    await abrir(t);
    await t.tap(find.text('Mensual'));
    await t.pump();
    expect(find.textContaining('Octubre 2026 • '), findsOneWidget);
    expect(find.text('OCTUBRE'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Mes siguiente'));
    await t.pump();
    expect(find.textContaining('Noviembre 2026 • '), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Martes, 3 de Noviembre 2026'));
    await t.pump();
    expect(find.textContaining('Martes, 3 de Noviembre 2026 • '), findsOneWidget);
    expect(find.text('Semana 45'), findsOneWidget);
  });

  testWidgets('Agenda: vista semanal agrupa las sesiones por día', (t) async {
    await abrir(t);
    await t.tap(find.text('Semanas'));
    await t.pump();
    expect(find.textContaining('Semana 42 · 12–18 Oct'), findsOneWidget);
    expect(find.text('JUEVES 15 OCT'), findsOneWidget);
    expect(find.text('SÁBADO 17 OCT'), findsOneWidget);
    expect(find.text('HOY'), findsOneWidget);

    await t.tap(find.text('SÁBADO 17 OCT'));
    await t.pump();
    expect(find.text('Sábado, 17 de Octubre 2026 • 2\nsesiones'), findsOneWidget);
  });
}
