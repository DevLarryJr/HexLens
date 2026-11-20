import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_agenda.dart';
import 'package:proyecto_movil/navegacion.dart';
import 'package:proyecto_movil/screens/sesion_detalle_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/utils/formato.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('iniciales', () {
    expect(iniciales('Laura Méndez'), 'LM');
    expect(iniciales('  mateo   ríos  '), 'MR');
  });

  Future<void> abrir(WidgetTester t, Widget pantalla) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: pantalla,
    ));
  }

  testWidgets('Detalle: por defecto muestra la sesión en gestión desde los modelos', (t) async {
    await abrir(t, const SesionDetalleScreen());
    expect(find.text('#RSV-2026-042'), findsOneWidget);
    expect(find.text('C.C. 1.025.340.890 •\nBogotá D.C.'), findsOneWidget);
    expect(find.text('+57 312 987 6543'), findsOneWidget);
    expect(find.text('10:00 - 10:45 AM'), findsOneWidget);
    expect(find.text('Comisión\n30%'), findsOneWidget);
    expect(find.text('\$36.000 COP'), findsOneWidget);
    expect(find.text('Transferencia bancaria'), findsOneWidget);
  });

  testWidgets('Detalle: refleja otra sesión (Andrés, Mateo, 35 %)', (t) async {
    final andres = sesionesAgenda.firstWhere((s) => s.cliente == 'Andrés Molina');
    await abrir(t, SesionDetalleScreen(sesion: andres));
    expect(find.text('Andrés Molina'), findsOneWidget);
    expect(find.text('11:30 AM - 12:30 PM'), findsOneWidget);
    expect(find.text('Especialidad:\nFamiliar'), findsOneWidget);
    expect(find.text('MR'), findsOneWidget);
    expect(find.text('Comisión\n35%'), findsOneWidget);
    expect(find.text('\$63.000 COP'), findsOneWidget);
  });

  testWidgets('Detalle: una sola salida, y el header dice a dónde vuelve', (t) async {
    await abrir(
      t,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => Rutas.push(context, const SesionDetalleScreen(), desde: 'Inicio'),
          child: const Text('abrir'),
        ),
      ),
    );
    await t.tap(find.text('abrir'));
    await t.pumpAndSettle();

    expect(find.text('Volver a Agenda'), findsNothing);
    expect(find.text('INICIO ›'), findsOneWidget);
    expect(find.bySemanticsLabel('Volver a Inicio'), findsOneWidget);
    expect(find.text('#RSV-2026-042'), findsOneWidget);

    await t.tap(find.bySemanticsLabel('Volver a Inicio'));
    await t.pumpAndSettle();
    expect(find.byType(SesionDetalleScreen), findsNothing);
    expect(find.text('abrir'), findsOneWidget);
  });

  testWidgets('Detalle: sin origen conocido, el header no inventa uno', (t) async {
    await abrir(t, const SesionDetalleScreen());
    expect(find.textContaining('›'), findsNothing);
    expect(find.bySemanticsLabel('Volver'), findsOneWidget);
  });
}
