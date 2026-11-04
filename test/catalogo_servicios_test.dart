import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/api/api.dart';
import 'package:proyecto_movil/data/mock_agenda.dart';
import 'package:proyecto_movil/data/mock_servicios.dart';
import 'package:proyecto_movil/screens/catalogo_servicios_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';
import 'package:proyecto_movil/widgets/servicios/servicio_catalogo_cards.dart';

import 'api_falsa.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  test('Servicios: códigos únicos y cada pantalla con sus 6', () {
    final codigos = serviciosEstudio.map((s) => s.codigo).toSet();
    expect(codigos.length, serviciosEstudio.length);
    expect(serviciosCatalogo.length, 6);
    expect(serviciosReserva.length, 6);
    expect(serviciosReserva.first, same(serviciosCatalogo.first)); // mismo Retrato profesional
  });

  test('Servicios: las sesiones de la agenda cobran la tarifa del catálogo', () {
    for (final s in sesionesAgenda.where((s) => s.precio != null)) {
      final nombre = s.descripcion.isEmpty ? s.nombreServicio : s.descripcion;
      final candidatos = serviciosEstudio.where((x) => nombre.startsWith(x.nombre)).toList()
        ..sort((a, b) => b.nombre.length.compareTo(a.nombre.length));
      final servicio = candidatos.firstOrNull;
      if (servicio != null) expect(s.precio, servicio.precio, reason: nombre);
    }
  });

  Future<void> abrir(WidgetTester t) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const CatalogoServiciosScreen(),
    ));
  }

  testWidgets('Catálogo: conteos, filtro por categoría y "Editar Tarifa" abre la edición', (t) async {
    await abrir(t);
    expect(find.text('6 SERVICIOS ACTIVOS'), findsOneWidget);
    expect(find.byType(ServicioCatalogoCard), findsNWidgets(6));

    await t.tap(find.text('Familiar'));
    await t.pump();
    expect(find.byType(ServicioCatalogoCard), findsNWidgets(2));

    await t.tap(find.text('Editar Tarifa').first);
    await t.pumpAndSettle();
    expect(find.text('Editar Servicio'), findsOneWidget);
    expect(find.text('Sesión familiar'), findsWidgets); // título y nombre bloqueado
    expect(find.text('180.000'), findsOneWidget);
  });

  testWidgets('Catálogo con la API: servicios reales con el nombre de su especialidad', (t) async {
    usarApiFalsa(
      especialidades: [
        {'id': 15, 'nombre': 'Retratos'},
      ],
      servicios: [
        {'id': 7, 'nombre': 'Sesión de retrato', 'precio': 150000, 'descripcion': '10 fotos', 'duracion': 60, 'especialidad': 15},
        {'Id': 8, 'Nombre': 'Retrato express', 'Precio': 90000.0, 'Descripcion': '3 fotos', 'Duracion': 30, 'EspecialidadId': 15},
      ],
    );
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    await abrir(t);
    await t.pumpAndSettle();
    expect(find.byType(ServicioCatalogoCard), findsNWidgets(2));
    expect(find.text('#SRV-007'), findsOneWidget);
    expect(find.text('Retrato express'), findsOneWidget);
    expect(serviciosEstudio.last.precio, 90000);
    expect(serviciosEstudio.last.categoria, 'Retratos');
    await Api.cerrarSesion();
  });
}
