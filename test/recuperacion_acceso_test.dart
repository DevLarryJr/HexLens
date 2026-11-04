import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/recuperacion_acceso_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 5000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const RecuperacionAccesoScreen(),
    ));
  }

  Color? check(WidgetTester t) => t.widget<Icon>(find.byIcon(Icons.verified_outlined)).color;

  Iterable<Container> conBorde(WidgetTester t) => t
      .widgetList<Container>(find.byType(Container))
      .where((c) => c.decoration is BoxDecoration && (c.decoration! as BoxDecoration).border != null);

  testWidgets('Recuperación: correo, C.C. o ID válidos; texto suelto no', (t) async {
    await abrir(t);
    expect(check(t), AppColors.accent);

    final campo = find.byType(TextField).first;
    for (final (texto, ok) in [('abcd', false), ('1020345981', true), ('HL-084', true), ('a@b', false)]) {
      await t.enterText(campo, texto);
      await t.pump();
      expect(check(t), ok ? AppColors.accent : AppColors.outlineVariant, reason: texto);
    }
  });

  testWidgets('Recuperación: la casilla activa se marca al enfocar el código', (t) async {
    await abrir(t);
    expect(conBorde(t), isEmpty);
    await t.tap(find.text('7'));
    await t.pump();
    expect(conBorde(t), hasLength(1));
    await t.pumpWidget(const SizedBox()); // detiene el temporizador
  });
}
