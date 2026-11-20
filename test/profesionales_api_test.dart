import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_movil/data/mock_especialidades.dart';
import 'package:proyecto_movil/data/mock_fotografos.dart';
import 'package:proyecto_movil/models/fotografo.dart';
import 'package:proyecto_movil/models/servicio.dart';

import 'api_falsa.dart';

Future<void> conectar(
  List<Map<String, Object?>> profesionales, {
  List<Map<String, Object?>> servicios = const [],
}) async {
  usarApiFalsa(
    especialidades: [
      {'id': 15, 'nombre': 'Retratos'},
    ],
    servicios: servicios,
    profesionales: profesionales,
  );
  await iniciarSesion(usuarioPrueba, clavePrueba);
  await sincronizarEspecialidades();
  await sincronizarFotografos();
}

void main() {
  tearDown(SesionActual.cerrar);

  test('El staff se llena con los profesionales de la API', () async {
    await conectar([
      {'id': 17, 'documento': '9876543210', 'nombres': 'Ana', 'apellidos': 'López', 'porcentaje': 40, 'estado': true, 'especialidad': 15},
      {'Id': 18, 'Documento': '52890123', 'Nombres': 'Juan', 'Apellidos': 'Pérez', 'Porcentaje': 35.0, 'Estado': false, 'Especialidad': 15},
    ]);
    expect(fotografos.map((f) => f.nombre), ['Ana López', 'Juan Pérez']);
    final ana = fotografos.first;
    expect(ana.id, 17);
    expect(ana.documento, 'C.C. 9.876.543.210');
    expect(ana.especialidad, 'Retratos');
    expect(ana.comisionPct, 40);
    expect(ana.foto, isNull);
    expect(fotografos.last.estado, EstadoFotografo.inactivo);
    expect(fotografoEjemplo('Laura Méndez').foto, isNotNull);
  });

  test('Registrar: POST /api/profesionales con el formato de la API', () async {
    await conectar([]);
    final nuevo = await registrarFotografo(
      documento: '1.020.845.920',
      nombres: ' Laura Camila ',
      apellidos: 'Méndez Ríos',
      nacimiento: DateTime(1996, 8, 14),
      comisionPct: 30,
      activo: true,
      especialidad: especialidades.single,
    );
    expect(jsonDecode(peticionesRecibidas.last.body), {
      'Documento': '1020845920',
      'Nombres': 'Laura Camila',
      'Apellidos': 'Méndez Ríos',
      'FechaNacimiento': '1996-08-14',
      'Porcentaje': 30,
      'Estado': true,
      'Especialidad': 15,
    });
    expect(nuevo.id, 300);
    expect(nuevo.nombre, 'Laura Camila Méndez Ríos');
    expect(fotografos.last, same(nuevo));
  });

  test('Condiciones y reactivar: PUT /api/profesionales/{id} con lo que cambia', () async {
    await conectar([
      {'id': 17, 'documento': '9876543210', 'nombres': 'Ana María', 'apellidos': 'López', 'porcentaje': 40, 'estado': false, 'especialidad': 15},
    ]);
    final ana = fotografos.single;

    final editada = await actualizarCondiciones(ana,
        nombreCompleto: 'Ana Sofía López', comisionPct: 45, especialidad: especialidades.single);
    expect(peticionesRecibidas.last.method, 'PUT');
    expect(peticionesRecibidas.last.url.path, '/api/profesionales/17');
    expect(jsonDecode(peticionesRecibidas.last.body),
        {'Nombres': 'Ana Sofía', 'Apellidos': 'López', 'Porcentaje': 45, 'Especialidad': 15});
    expect(editada.nombre, 'Ana Sofía López');

    final activa = await cambiarEstadoFotografo(editada, activo: true);
    expect(jsonDecode(peticionesRecibidas.last.body), {'Estado': true});
    expect(activa.estado, isNot(EstadoFotografo.inactivo));
    expect(fotografos.single, same(activa));
  });

  test('Fotógrafo de una reserva: GET /api/profesionales/{servicioId}/especialiades, solo activos', () async {
    await conectar([
      {'id': 18, 'nombres': 'Juan', 'apellidos': 'Pérez', 'porcentaje': 35, 'estado': false, 'especialidad': 15},
      {'id': 17, 'nombres': 'Ana', 'apellidos': 'López', 'porcentaje': 40, 'estado': true, 'especialidad': 15},
      {'id': 19, 'nombres': 'Otro', 'apellidos': 'Más', 'porcentaje': 30, 'estado': true, 'especialidad': 99},
    ], servicios: [
      {'id': 58, 'nombre': 'Retrato', 'precio': 150000, 'duracion': 60, 'especialidad': 15},
    ]);
    const retrato = Servicio(
        id: 58, codigo: '#SRV-058', nombre: 'Retrato', categoria: 'Retratos', especialidadId: 15,
        duracionMin: 60, descripcion: '', precio: 150000);
    final sugerido = await fotografoSugerido(retrato);
    expect(peticionesRecibidas.last.url.path, '/api/profesionales/58/especialiades');
    expect(sugerido?.nombre, 'Ana López');
    expect(sugerido?.comisionPct, 40);
    final antes = peticionesRecibidas.length;
    await fotografosParaServicio(retrato);
    expect(peticionesRecibidas.length, antes);
  });
}
