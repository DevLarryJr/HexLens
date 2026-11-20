import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_fotografos.dart';
import 'package:proyecto_movil/screens/actualizar_condiciones_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/widgets/condiciones/condiciones_widgets.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> abrir(WidgetTester t, Widget pantalla) async {
    t.view.physicalSize = const Size(1600, 6000);
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

  testWidgets('Condiciones: sin fotógrafo muestra el estado de error del diseño', (t) async {
    await abrir(t, const ActualizarCondicionesScreen());
    expect(find.byType(ErrorGuardarBanner), findsOneWidget);
    expect(find.text('2 errores'), findsOneWidget);
    expect(find.text('Retratos'), findsOneWidget);
  });

  testWidgets('Condiciones: con fotógrafo se rellena desde el modelo y valida', (t) async {
    await abrir(t, ActualizarCondicionesScreen(fotografo: fotografoPorNombre('Mateo Ríos')));
    expect(find.byType(ErrorGuardarBanner), findsNothing);
    expect(find.text('TODO\nCORRECTO'), findsOneWidget);
    expect(find.text('80.124.567'), findsOneWidget);
    expect(find.text('Familiar'), findsOneWidget);
    expect(find.text('35'), findsOneWidget);
  });
}
