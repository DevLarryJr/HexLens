import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/models/jornada.dart';
import 'package:proyecto_movil/screens/horario_semanal_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/widgets/hex_widgets.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('Jornada: horas efectivas y horario', () {
    final d = DateTime(2026, 10, 12);
    expect(Jornada(fecha: d, inicioMin: 480, finMin: 1020).horas, '8h');
    expect(Jornada(fecha: d, inicioMin: 540, finMin: 840, almuerzo: false).horas, '5h');
    expect(Jornada(fecha: d, inicioMin: 480, finMin: 1020).horario, '08:00 - 17:00');
    expect(Jornada(fecha: d).libre, isTrue);
  });

  testWidgets('Horario: semana de hoy, métricas calculadas y flechas que mueven los días', (t) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const HorarioSemanalScreen(),
    ));

    expect(find.text('Sem 42 • Octubre 2026'), findsOneWidget);
    expect(find.text('40h'), findsOneWidget);
    expect(find.text('5 Días'), findsOneWidget);
    expect(find.text('HOY'), findsOneWidget);
    expect(find.text('15'), findsOneWidget);
    expect(find.text('Hoy en estudio: 3 sesiones agendadas'), findsOneWidget);

    await t.tap(find.byWidgetPredicate((w) => w is SvgIcon && w.path == 'horario/chevron_right.svg'));
    await t.pump();
    expect(find.text('SEMANA +1'), findsOneWidget);
    expect(find.text('Sem 43 • Octubre 2026'), findsOneWidget);
    expect(find.text('19'), findsOneWidget);
    expect(find.text('HOY'), findsNothing);
  });
}
