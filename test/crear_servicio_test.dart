import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_especialidades.dart';
import 'package:proyecto_movil/data/mock_servicios.dart';
import 'package:proyecto_movil/screens/crear_servicio_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/utils/formato.dart';

import 'api_falsa.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('nombreCorto', () {
    expect(nombreCorto('Laura Méndez'), 'Laura M.');
    expect(nombreCorto('Cher'), 'Cher');
  });

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
      home: const CrearServicioScreen(),
    ));
  }

  testWidgets('Crear servicio: especialidad y reparto desde los modelos', (t) async {
    await abrir(t);
    await t.enterText(find.byType(TextField).at(2), '140000');
    await t.pump();
    expect(find.text('140.000'), findsOneWidget, reason: 'el precio se separa al escribir');
    expect(find.text('Retratos'), findsOneWidget);
    expect(find.textContaining('Laura M.', findRichText: true), findsOneWidget);
    expect(find.textContaining('Carlos', findRichText: true), findsNothing);
    expect(find.text('Comisión fotógrafo estimada (30%):'), findsOneWidget);
    expect(find.text('\$42.000 COP'), findsOneWidget);

    await t.tap(find.text('Retratos'));
    await t.pumpAndSettle();
    await t.tap(find.text('Editorial').last);
    await t.pumpAndSettle();
    expect(find.text('Comisión fotógrafo estimada (40%):'), findsOneWidget);
    expect(find.text('Margen base estudio (60%):'), findsOneWidget);
    expect(find.text('\$56.000 COP'), findsOneWidget);
    expect(find.textContaining('Nicolás V.', findRichText: true), findsOneWidget);
  });

  testWidgets('Crear servicio con la API: valida y envía Nombre, Precio, Descripcion, Duracion y Especialidad',
      (t) async {
    usarApiFalsa(especialidades: [
      {'id': 15, 'nombre': 'Retratos'},
    ]);
    await iniciarSesion(usuarioPrueba, clavePrueba);
    await sincronizarEspecialidades();
    await abrir(t);

    await t.tap(find.text('Guardar Servicio'));
    await t.pump();
    expect(find.text('La descripción es obligatoria.'), findsOneWidget);
    expect(peticionesRecibidas.where((p) => p.method == 'POST' && p.url.path == '/api/servicios'), isEmpty);

    await t.enterText(find.byType(TextField).at(0), 'Sesión de retrato');
    await t.enterText(find.byType(TextField).at(1), 'Sesión de 1 hora con 10 fotos editadas');
    await t.enterText(find.byType(TextField).at(2), '150000');
    await t.tap(find.text('60'));
    await t.tap(find.text('Guardar Servicio'));
    await t.pumpAndSettle();

    expect(jsonDecode(peticionesRecibidas.last.body), {
      'Nombre': 'Sesión de retrato',
      'Precio': 150000,
      'Descripcion': 'Sesión de 1 hora con 10 fotos editadas',
      'Duracion': 60,
      'Especialidad': 15,
    });
    expect(serviciosEstudio.last.nombre, 'Sesión de retrato');
    expect(serviciosEstudio.last.id, 200);
    await SesionActual.cerrar();
  });
}
