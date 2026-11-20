import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/nueva_reserva_servicio_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  testWidgets('Las categorías filtran los servicios y la selección se conserva', (t) async {
    t.view.physicalSize = const Size(1600, 6000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.8)),
        child: child!,
      ),
      home: const NuevaReservaServicioScreen(),
    ));

    expect(find.text('Retrato profesional'), findsOneWidget);
    expect(find.text('Sesión familiar en estudio'), findsNothing);

    await t.tap(find.text('Familiar'));
    await t.pump();
    expect(find.text('Servicios Familiares'), findsOneWidget);
    expect(find.text('Sesión familiar en estudio'), findsOneWidget);
    expect(find.text('Retrato profesional'), findsNothing);

    await t.tap(find.text('Sesión familiar en estudio'));
    await t.pump();
    expect(find.text('Disponible para Sesión familiar en estudio'), findsOneWidget);
    expect(find.textContaining('No cubre categoría Familiar'), findsOneWidget);
    expect(find.textContaining('90 min'), findsWidgets);

    await t.tap(find.text('Todas'));
    await t.pump();
    expect(find.text('Retrato profesional'), findsOneWidget);
    expect(find.text('Editorial de moda'), findsOneWidget);
  });
}
