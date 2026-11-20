import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/registrar_inasistencia_screen.dart';
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
      home: const RegistrarInasistenciaScreen(),
    ));
  }

  String analisis(WidgetTester t) => t
      .widgetList<RichText>(find.byType(RichText))
      .map((r) => r.text.toPlainText())
      .firstWhere((s) => s.startsWith('Análisis de reservas'));

  testWidgets('Inasistencia: rango por defecto sin conflictos', (t) async {
    await abrir(t);
    expect(analisis(t), contains('28-29 Oct 2026: 0 citas programadas para Laura Méndez'));
    expect(find.text('Sin conflictos\ndetectados'), findsOneWidget);
  });

  testWidgets('Inasistencia: un día con reservas de Laura muestra el conflicto', (t) async {
    await abrir(t);
    await t.tap(find.text('Día específico (1 día)'));
    await t.pump();
    await t.tap(find.text('28/10/2026'));
    await t.pumpAndSettle();
    await t.tap(find.text('15'));
    await t.tap(find.text('OK'));
    await t.pumpAndSettle();

    expect(analisis(t), contains('15 Oct 2026: 1 cita programada para Laura Méndez'));
    expect(find.text('1 conflicto\ndetectado'), findsOneWidget);
  });
}
