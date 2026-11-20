import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyecto_movil/data/mock_especialidades.dart';
import 'package:proyecto_movil/data/mock_fotografos.dart';
import 'package:proyecto_movil/data/mock_horario.dart';
import 'package:proyecto_movil/models/jornada.dart';
import 'package:proyecto_movil/screens/configurar_jornada_screen.dart';
import 'package:proyecto_movil/screens/horario_semanal_screen.dart';
import 'package:proyecto_movil/theme/app_theme.dart';

import 'api_falsa.dart';

final lunes = DateTime(2026, 10, 12);

Future<void> conectar(List<Map<String, Object?>> horarios) async {
  usarApiFalsa(
    especialidades: [
      {'id': 15, 'nombre': 'Retratos'},
    ],
    profesionales: [
      {'id': 17, 'nombres': 'Ana', 'apellidos': 'López', 'porcentaje': 40, 'estado': true, 'especialidad': 15},
      {'id': 18, 'nombres': 'Juan', 'apellidos': 'Pérez', 'porcentaje': 35, 'estado': true, 'especialidad': 15},
    ],
    horariosLaborales: horarios,
  );
  await iniciarSesion(usuarioPrueba, clavePrueba);
  await sincronizarEspecialidades();
  await sincronizarFotografos();
}

const juevesAna = {
  'id': 1,
  'profesionalId': 17,
  'diaSemana': 4,
  'horaInicio': '07:00:00',
  'horaFin': '15:00:00',
  'tieneAlmuerzo': true,
  'horaInicioAlmuerzo': '12:00:00',
  'horaFinAlmuerzo': '12:30:00',
};

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);
  tearDown(SesionActual.cerrar);

  test('Sin sesión no hay fotógrafo de la API: se usa la semana de ejemplo', () {
    expect(fotografoJornada, isNull);
    expect(semanaDe(null, lunes).first.horario, '08:00 - 17:00');
  });

  test('La semana se arma con GET /api/horarios-laboral/profesional/{id}', () async {
    await conectar([juevesAna]);
    final ana = fotografoJornada!;
    expect(ana.nombre, 'Ana López');
    expect(horariosCargados(ana), isFalse);

    await cargarHorarios(ana);
    expect(peticionesRecibidas.last.url.path, '/api/horarios-laboral/profesional/17');
    expect(horariosCargados(ana), isTrue);

    final semana = semanaDe(ana, lunes);
    expect(semana, hasLength(7));
    final jueves = semana[3];
    expect(jueves.fecha, DateTime(2026, 10, 15));
    expect(jueves.horario, '07:00 - 15:00');
    expect(jueves.almuerzoInicioMin, 12 * 60);
    expect(jueves.almuerzoFinMin, 12 * 60 + 30);
    expect(jueves.minutosEfectivos, 450);
    expect(semana[0].libre, isTrue);
    expect(semana[6].libre, isTrue);
  });

  test('Guardar: PUT si el día ya tiene horario, POST si no (domingo = diaSemana 0)', () async {
    await conectar([juevesAna]);
    final ana = fotografoJornada!;
    await cargarHorarios(ana);
    peticionesRecibidas.clear();

    await guardarJornadas(ana, {
      DateTime.thursday: Jornada(fecha: DateTime(2026, 10, 15), inicioMin: 7 * 60 + 30, finMin: 15 * 60, almuerzo: false),
      DateTime.sunday: Jornada(
        fecha: DateTime(2026, 10, 18),
        inicioMin: 9 * 60,
        finMin: 13 * 60,
        almuerzo: true,
        almuerzoInicioMin: 11 * 60,
        almuerzoFinMin: 11 * 60 + 15,
      ),
    });

    final put = peticionesRecibidas.firstWhere((p) => p.method == 'PUT');
    expect(put.url.path, '/api/horarios-laboral/1');
    expect(jsonDecode(put.body), {'horaInicio': '07:30:00', 'horaFin': '15:00:00', 'tieneAlmuerzo': false});

    final post = peticionesRecibidas.firstWhere((p) => p.method == 'POST');
    expect(post.url.path, '/api/horarios-laboral');
    expect(jsonDecode(post.body), {
      'profesionalId': 17,
      'diaSemana': 0,
      'horaInicio': '09:00:00',
      'horaFin': '13:00:00',
      'tieneAlmuerzo': true,
      'horaInicioAlmuerzo': '11:00:00',
      'horaFinAlmuerzo': '11:15:00',
    });

    expect(peticionesRecibidas.last.method, 'GET');
    final semana = semanaDe(ana, lunes);
    expect(semana[3].horario, '07:30 - 15:00');
    expect(semana[3].almuerzo, isFalse);
    expect(semana[6].horario, '09:00 - 13:00');
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
    await t.pumpAndSettle();
  }

  testWidgets('Horario Semanal con la API: muestra al fotógrafo y su jornada, y permite cambiarlo', (t) async {
    await conectar([juevesAna]);
    await abrir(t, const HorarioSemanalScreen());

    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('Laura Méndez'), findsNothing);
    expect(peticionesRecibidas.last.url.path, '/api/horarios-laboral/profesional/17');

    await t.tap(find.text('CAMBIAR'));
    await t.pumpAndSettle();
    await t.tap(find.text('Juan Pérez'));
    await t.pumpAndSettle();
    expect(find.text('Juan Pérez'), findsOneWidget);
    expect(peticionesRecibidas.last.url.path, '/api/horarios-laboral/profesional/18');
    expect(fotografoJornada?.nombre, 'Juan Pérez');
  });

  testWidgets('Configurar Jornada con la API: carga el jueves de Ana y guarda con PUT', (t) async {
    await conectar([juevesAna]);
    elegirFotografoJornada(fotografos.firstWhere((f) => f.id == 17));
    await abrir(t, const ConfigurarJornadaScreen());

    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('07:00 AM'), findsOneWidget);
    expect(find.text('03:00 PM'), findsOneWidget);
    expect(find.text('12:00 PM'), findsOneWidget);
    expect(find.text('12:30 PM'), findsOneWidget);

    await t.tap(find.textContaining('Aplicar'));
    await t.pump();
    await t.tap(find.byIcon(Icons.keyboard_arrow_up).first);
    await t.pump();
    expect(find.text('07:30 AM'), findsOneWidget);
    peticionesRecibidas.clear();

    await t.tap(find.text('Guardar Jornada Laboral'));
    await t.pumpAndSettle();
    final put = peticionesRecibidas.singleWhere((p) => p.method == 'PUT');
    expect(put.url.path, '/api/horarios-laboral/1');
    expect(jsonDecode(put.body)['horaInicio'], '07:30:00');
    expect(peticionesRecibidas.where((p) => p.method == 'POST'), isEmpty);
    expect(horariosLaboralesGuardados.single['horaInicio'], '07:30:00');
  });
}
