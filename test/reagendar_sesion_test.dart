import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_agenda.dart';
import 'package:proyecto_movil/data/mock_reagendar.dart';
import 'package:proyecto_movil/screens/reagendar_sesion_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Reagendar: fecha y franja elegidas se reflejan en los textos', (t) async {
    t.view.physicalSize = const Size(1600, 6000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.8)),
        child: child!,
      ),
      home: const ReagendarSesionScreen(),
    ));

    expect(find.text('Jueves, 22 de Octubre 2026'), findsOneWidget);
    expect(find.text('Original: 15\nOct'), findsOneWidget);
    expect(find.textContaining('#RSV-2026-042'), findsOneWidget);
    expect(find.text('C.C. 1.025.340.890'), findsOneWidget);

    // Días ya pasados (antes de hoy, 15 oct) bloqueados.
    await t.tap(find.text('13'));
    await t.pump();
    expect(find.text('Jueves, 22 de Octubre 2026'), findsOneWidget);
    // La franja arranca a la misma hora de la sesión original.
    expect(find.text('Sin conflicto en franja de 10:00 AM'), findsOneWidget);

    await t.tap(find.text('24'));
    await t.pump();
    expect(find.text('Sábado, 24 de Octubre 2026'), findsOneWidget);

    // Día bloqueado: no cambia la selección.
    await t.tap(find.text('25'));
    await t.pump();
    expect(find.text('Sábado, 24 de Octubre 2026'), findsOneWidget);

    await t.tap(find.text('02:15 PM'));
    await t.pump();
    expect(find.text('Sin conflicto en franja de 02:15 PM'), findsOneWidget);
    expect(find.text('Franja seleccionada: 02:15 PM (45 min)'), findsOneWidget);
  });

  testWidgets('Reagendar: se navega por los meses y confirmar mueve la sesión en la agenda', (t) async {
    t.view.physicalSize = const Size(1600, 6000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.8)),
        child: child!,
      ),
      home: const ReagendarSesionScreen(),
    ));
    final sesion = sesionEnGestion;

    // No se puede ir a meses pasados; sí a los siguientes.
    await t.tap(find.bySemanticsLabel('Mes anterior'));
    await t.pump();
    expect(find.text('Octubre 2026'), findsOneWidget);
    await t.tap(find.bySemanticsLabel('Mes siguiente'));
    await t.pump();
    expect(find.text('Noviembre 2026'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Martes, 10 de Noviembre 2026'));
    await t.pump();
    expect(find.text('Martes, 10 de Noviembre 2026'), findsOneWidget);
    await t.tap(find.text('02:15 PM'));
    await t.pump();

    await t.tap(find.text('Confirmar Reagendamiento'));
    await t.pump();
    final movida = sesionesAgenda.firstWhere((s) => s.cliente == sesion.cliente && s.codigo == sesion.codigo);
    expect(movida.inicio, DateTime(2026, 11, 10, 14, 15));
    expect(sesionesAgenda.where((s) => identical(s, sesion)), isEmpty);
  });

  test('Franjas: ocupadas según la agenda del fotógrafo; domingos y ausencias bloqueados', () {
    final sesion = sesionesAgenda.firstWhere((s) => s.cliente == 'Valentina Ruiz'); // de Laura Méndez
    // El viernes 16 Laura tiene una sesión a las 9:00 (90 min): la franja de 9:00 y la de 10:00 se cruzan.
    final viernes = franjasReagendar(DateTime(2026, 10, 16), sesion);
    expect(viernes.firstWhere((f) => f.hora == '09:00 AM').bloqueo, 'OCUPADO');
    expect(viernes.firstWhere((f) => f.hora == '05:00 PM').bloqueo, 'CIERRE');
    expect(diaBloqueadoReagendar(DateTime(2026, 10, 18), sesion.fotografo), isTrue, reason: 'domingo');
    expect(diaBloqueadoReagendar(DateTime(2026, 10, 28), sesion.fotografo), isTrue, reason: 'capacitación de Laura');
    expect(diaBloqueadoReagendar(DateTime(2026, 10, 27), sesion.fotografo), isFalse);
  });
}
