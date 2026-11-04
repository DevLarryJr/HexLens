import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/api/api.dart';
import 'package:proyecto_movil/data/mock_agenda.dart';
import 'package:proyecto_movil/data/mock_clientes.dart';
import 'package:proyecto_movil/data/mock_especialidades.dart';
import 'package:proyecto_movil/data/mock_servicios.dart';
import 'package:proyecto_movil/main.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

import 'api_falsa.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(Api.cerrarSesion);

  testWidgets('Nueva reserva de punta a punta con la API: cliente → servicio → hora → confirmar', (t) async {
    t.view.physicalSize = const Size(1600, 8000);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    usarApiFalsa(
      clientes: [
        {'id': 1, 'documento': '1098765432', 'nombres': 'Larry', 'apellidos': 'Sánchez', 'celular': '3001234567'},
      ],
      especialidades: [
        {'id': 15, 'nombre': 'Retratos'},
      ],
      servicios: [
        {'id': 7, 'nombre': 'Sesión de retrato', 'precio': 150000, 'descripcion': '10 fotos', 'duracion': 60, 'especialidad': 15},
      ],
      profesionales: [
        {'id': 17, 'nombres': 'Ana', 'apellidos': 'López', 'porcentaje': 40, 'estado': true, 'especialidad': 15},
      ],
      horarios: const ['10:30', '14:00'],
    );
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    await sincronizarClientes();
    await sincronizarEspecialidades();
    await sincronizarServicios();
    await sincronizarAgenda();

    // La fuente de pruebas (Ahem) es más ancha que Noto Sans; este test solo mira lógica.
    await t.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(0.6)),
        child: child!,
      ),
      home: const HomeShell(),
    ));
    await t.tap(find.text('Agenda').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Nueva'));
    await t.pumpAndSettle();

    // Paso 1: el cliente de la API viene elegido.
    expect(find.text('Larry Sánchez'), findsOneWidget);
    await t.tap(find.text('Continuar a Servicio y Fotógrafo'));
    await t.pumpAndSettle();

    // Paso 2: el servicio de la API, y el resumen muestra al cliente elegido.
    expect(find.textContaining('Larry Sánchez', findRichText: true), findsOneWidget);
    expect(find.text('Sesión de retrato'), findsOneWidget);
    await t.tap(find.text('Continuar'));
    await t.pumpAndSettle();

    // Paso 3: los horarios salen de GET /api/agenda, y el fotógrafo de los profesionales de la especialidad.
    final agenda = peticionesRecibidas.lastWhere((p) => p.url.path == '/api/agenda');
    expect(agenda.url.queryParameters['servicioId'], '7');
    expect(agenda.url.queryParameters['profesionalId'], '17');
    expect(find.textContaining('10:30'), findsWidgets);
    expect(find.textContaining('Ana López'), findsWidgets);
    await t.tap(find.text('Continuar a Confirmación'));
    await t.pumpAndSettle();

    // Paso 4: confirmar crea la reserva en la API y vuelve a la agenda.
    expect(find.textContaining('Larry Sánchez', findRichText: true), findsWidgets);
    expect(find.text('Ana López'), findsOneWidget);
    await t.tap(find.text('Confirmar reserva'));
    await t.pumpAndSettle();
    final post = peticionesRecibidas.lastWhere((p) => p.method == 'POST' && p.url.path == '/api/reservas');
    final cuerpo = jsonDecode(post.body) as Map;
    expect(cuerpo['ServicioId'], 7);
    expect(cuerpo['ClienteId'], 1);
    expect(cuerpo['Fecha'], endsWith('T10:30:00'));
    expect(sesionesAgenda.where((s) => s.cliente == 'Larry Sánchez'), hasLength(1));
    expect(find.textContaining('confirmada'), findsOneWidget);
    expect(clientes, isNotEmpty);
    expect(especialidades, isNotEmpty);
    expect(serviciosEstudio, isNotEmpty);
  });
}
