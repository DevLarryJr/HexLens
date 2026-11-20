import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_especialidades.dart';
import 'package:proyecto_movil/screens/catalogo_especialidades_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

import 'api_falsa.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(SesionActual.cerrar);

  test('titularDe: el fotógrafo con esa especialidad', () {
    expect(titularDe('Retratos')?.nombre, 'Laura Méndez');
    expect(titularDe('Eventos y Corporativo'), isNull);
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
      home: const CatalogoEspecialidadesScreen(),
    ));
    await t.pumpAndSettle();
  }

  testWidgets('Especialidades (sin sesión): titulares, editar y eliminar con confirmación', (t) async {
    await abrir(t);
    expect(find.text('Laura Méndez'), findsOneWidget);
    expect(find.text('5 especialidades'), findsOneWidget);

    await t.tap(find.text('Eliminar').last);
    await t.pumpAndSettle();
    expect(find.text('¿Eliminar "Eventos y Corporativo"?'), findsOneWidget);
    await t.tap(find.text('Cancelar'));
    await t.pumpAndSettle();
    expect(find.text('Eventos y Corporativo'), findsOneWidget);

    await t.tap(find.text('Eliminar').last);
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(TextButton, 'Eliminar'));
    await t.pumpAndSettle();
    expect(find.text('Eventos y Corporativo'), findsNothing);
    expect(find.text("Especialidad 'Eventos y Corporativo' eliminada"), findsOneWidget);
    expect(find.text('4 especialidades'), findsOneWidget);

    await t.tap(find.text('Editar').first);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, 'Retrato y Estudio');
    await t.tap(find.text('Guardar'));
    await t.pumpAndSettle();
    expect(find.text('Retrato y Estudio'), findsOneWidget);
  });

  testWidgets('Especialidades con la API: lista real, eliminar y error al eliminar', (t) async {
    usarApiFalsa(
      especialidades: [
        {'id': 15, 'nombre': 'Retratos'},
        {'Id': 16, 'Nombre': 'Bodas'},
      ],
      conServicios: 15,
    );
    await iniciarSesion(usuarioPrueba, clavePrueba);
    await abrir(t);
    expect(find.text('2 especialidades'), findsOneWidget);
    expect(find.text('Bodas'), findsOneWidget);
    expect(find.text('Familiar'), findsNothing, reason: 'sin los datos de ejemplo');

    await t.tap(find.text('Eliminar').first);
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(TextButton, 'Eliminar'));
    await t.pumpAndSettle();
    expect(find.text('No se puede eliminar: tiene servicios asociados.'), findsOneWidget);
    expect(find.text('Retratos'), findsOneWidget);

    await t.tap(find.text('Eliminar').last);
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(TextButton, 'Eliminar'));
    await t.pumpAndSettle();
    expect(find.text('Bodas'), findsNothing);
    expect(peticionesRecibidas.last.method, 'DELETE');
    expect(peticionesRecibidas.last.url.path, '/api/especialidades/16');
  });

  test('Crear con la API: POST con {"Nombre"} y queda en la lista con su id', () async {
    usarApiFalsa();
    await iniciarSesion(usuarioPrueba, clavePrueba);
    final nueva = await crearEspecialidad('  Moda & Pasarela ');
    expect(jsonDecode(peticionesRecibidas.last.body), {'Nombre': 'Moda & Pasarela'});
    expect(nueva.id, 100);
    expect(especialidades.last, same(nueva));
  });
}
