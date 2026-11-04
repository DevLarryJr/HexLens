import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/inicio_admin_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Inicio: reservas y KPIs salen de las sesiones de hoy de la agenda', (t) async {
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
      home: InicioAdminScreen(onNuevaReserva: () {}, onAbrirSesion: (_) {}),
    ));

    expect(find.text('Jueves, 15 de octubre de 2026'), findsOneWidget);
    expect(find.text('4 turnos'), findsOneWidget);
    expect(find.text('Sesiones día'), findsOneWidget);
    expect(find.text('Realizada'), findsWidgets);
    expect(find.text('11:30 AM - 12:30 PM'), findsOneWidget);
    expect(find.text('Sesión familiar'), findsOneWidget); // nombre corto del servicio
    // La sesión cancelada de la agenda no aparece en las reservas de hoy.
    expect(find.textContaining('Cancelada por cliente'), findsNothing);

    // Orden: programadas por hora y la realizada al final.
    final y = [
      for (final c in ['Valentina Ruiz', 'Andrés Molina', 'Camila Pérez', 'Daniel Castro'])
        t.getTopLeft(find.text(c)).dy,
    ];
    expect(y, [...y]..sort());
  });
}
