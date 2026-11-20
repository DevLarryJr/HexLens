import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/screens/catalogo_fotografos_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const CatalogoFotografosScreen(),
    ));
  }

  testWidgets('Fotógrafos: reactivar cambia estado, acciones y contador', (t) async {
    await abrir(t);
    expect(find.text('3 fotógrafos activos en turno hoy'), findsOneWidget);
    expect(find.text('LICENCIA TEMPORAL'), findsOneWidget);
    expect(find.text('Ver Ficha'), findsNWidgets(3));

    await t.tap(find.text('Reactivar'));
    await t.pump();
    expect(find.text('4 fotógrafos activos en turno hoy'), findsOneWidget);
    expect(find.text('LICENCIA TEMPORAL'), findsNothing);
    expect(find.text('Reactivar'), findsNothing);
    expect(find.text('Comisiones'), findsNothing);
    expect(find.text('Ver Ficha'), findsNWidgets(4));
  });

  testWidgets('Fotógrafos: filtro por especialidad y búsqueda', (t) async {
    await abrir(t);
    await t.tap(find.text('Productos'));
    await t.pump();
    expect(find.text('Sara Torres'), findsOneWidget);
    expect(find.text('Laura Méndez'), findsNothing);

    await t.tap(find.text('Todos'));
    await t.enterText(find.byType(TextField), 'canon');
    await t.pump();
    expect(find.text('Mateo Ríos'), findsOneWidget);
    expect(find.text('Sara Torres'), findsNothing);
  });
}
