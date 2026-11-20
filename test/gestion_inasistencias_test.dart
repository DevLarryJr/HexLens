import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/models/inasistencia.dart';
import 'package:proyecto_movil/screens/gestion_inasistencias_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('Inasistencia: días y vigencia', () {
    final i = Inasistencia(
      id: 'x',
      fotografo: 'Ana',
      tipo: TipoInasistencia.licencia,
      categoria: '',
      titulo: '',
      desde: DateTime(2026, 10, 1),
      hasta: DateTime(2026, 10, 31),
      horario: '',
    );
    expect(i.dias, 31);
    expect(i.vigenteEn(DateTime(2026, 10, 31, 18)), isTrue);
    expect(i.vigenteEn(DateTime(2026, 11, 1)), isFalse);
  });

  testWidgets('Inasistencias: filtros por fecha y liberar actualiza los conteos', (t) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const GestionInasistenciasScreen(),
    ));

    expect(find.text('Capacitación Técnica Iluminación Profoto'), findsOneWidget);
    expect(find.text('Licencia Temporal Editorial'), findsOneWidget);
    expect(find.text('Permiso Médico Odontológico'), findsNothing);
    expect(find.text('0 citas afectadas. '), findsNothing);
    expect(find.textContaining('0 citas afectadas.'), findsOneWidget);

    await t.tap(find.text('Historial Pasado'));
    await t.pump();
    expect(find.text('Permiso Médico Odontológico'), findsOneWidget);
    expect(find.text('Licencia Temporal Editorial'), findsNothing);

    await t.tap(find.text('Todas'));
    await t.pump();
    expect(find.text('3'), findsOneWidget);
    await t.tap(find.text('Liberar Fechas'));
    await t.pump();
    expect(find.text('Capacitación Técnica Iluminación Profoto'), findsNothing);
    expect(find.text('2'), findsNWidgets(1));
  });
}
