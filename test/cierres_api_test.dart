import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_movil/api/api.dart';
import 'package:proyecto_movil/data/mock_agenda.dart';
import 'package:proyecto_movil/data/mock_cierres.dart';
import 'package:proyecto_movil/data/mock_fotografos.dart';
import 'package:proyecto_movil/models/cierre.dart';

import 'api_falsa.dart';

void main() {
  tearDown(Api.cerrarSesion);

  test('Los cierres son las liquidaciones de la API, del más reciente al más antiguo', () async {
    usarApiFalsa(liquidaciones: [
      {'id': 18, 'fechaInicio': '2026-09-16', 'fechaFin': '2026-09-30', 'totalFacturado': 1850000, 'totalComisiones': 610000, 'cantidadServicios': 12},
      {'Id': 19, 'FechaInicio': '2026-10-01T00:00:00', 'FechaFin': '2026-10-15T00:00:00', 'Total': 300000.0, 'Comisiones': 90000, 'Estado': 'Pagada'},
    ]);
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    await sincronizarCierres();
    expect(cierres.map((c) => c.codigo), ['#CIE-2026-10A', '#CIE-2026-09B']);
    final octubre = cierres.first;
    expect(octubre.id, 19);
    expect((octubre.total, octubre.staff, octubre.estudio), (300000, 90000, 210000));
    expect(octubre.estado, EstadoCierre.liquidado);
    expect(cierres.last.servicios, 12);
  });

  test('Generar un cierre: POST con fechaInicio y fechaFin', () async {
    usarApiFalsa();
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    final cierre = await generarCierre(DateTime(2026, 10, 16), DateTime(2026, 10, 31));
    expect(jsonDecode(peticionesRecibidas.last.body), {'fechaInicio': '2026-10-16', 'fechaFin': '2026-10-31'});
    expect(cierre.id, 500);
    expect(cierre.codigo, '#CIE-2026-10B');
    expect(cierre.total, 300000);
    expect(cierres.first, same(cierre));
  });

  test('Comisiones de un cierre, con sus servicios', () async {
    usarApiFalsa(
      profesionales: [
        {'id': 17, 'documento': '9876543210', 'nombres': 'Ana', 'apellidos': 'López', 'porcentaje': 40, 'estado': true, 'especialidad': 15},
      ],
      comisiones: [
        {'id': 53, 'profesional': {'id': 17, 'nombres': 'Ana', 'apellidos': 'López'}, 'porcentaje': 40},
      ],
      serviciosDeComision: [
        {'reservaId': 12, 'cliente': 'Larry Sánchez', 'servicio': 'Sesión de retrato', 'fecha': '2026-10-15T10:00:00', 'valor': 150000},
      ],
    );
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    await sincronizarFotografos();
    final liquidaciones = await liquidacionesDe(
      Cierre(id: 19, codigo: '#CIE-2026-10A', quincena: 1, inicio: DateTime(2026, 10), fin: DateTime(2026, 10, 15),
          estado: EstadoCierre.auditado, servicios: 1, total: 150000, staff: 60000),
    );
    expect(peticionesRecibidas.map((p) => p.url.toString()),
        containsAll(['$urlApi/api/comisiones?cierreId=19', '$urlApi/api/comisiones/53/servicios']));
    final ana = liquidaciones.single;
    expect(ana.fotografo.nombre, 'Ana López');
    expect(ana.tasa, 40);
    expect(ana.sesiones.single.cliente, 'Larry Sánchez');
    expect(ana.base, 150000);
    expect(ana.comision, 60000);
  });

  test('Vista previa con la API: sesiones terminadas y no canceladas de la agenda, por fotógrafo', () async {
    usarApiFalsa(
      profesionales: [
        {'id': 17, 'documento': '9876543210', 'nombres': 'Ana', 'apellidos': 'López', 'porcentaje': 40, 'estado': true, 'especialidad': 15},
      ],
      reservas: [
        {'id': 1, 'fecha': '2026-10-05T10:00:00', 'estado': 'Atendida', 'cliente': 'Larry Sánchez', 'servicio': {'nombre': 'Retrato', 'precio': 150000, 'duracion': 60}, 'profesional': 'Ana López'},
        {'id': 2, 'fecha': '2026-10-06T10:00:00', 'estado': 'Cancelada', 'cliente': 'X', 'servicio': {'nombre': 'Retrato', 'precio': 150000}, 'profesional': 'Ana López'},
        // Aún no ocurre (las pruebas corren el 15 oct a las 09:45): queda pendiente, no se liquida.
        {'id': 3, 'fecha': '2026-10-15T11:00:00', 'estado': 'Pendiente', 'cliente': 'Y', 'servicio': {'nombre': 'Retrato', 'precio': 150000}, 'profesional': 'Ana López'},
      ],
    );
    await Api.iniciarSesion(usuarioPrueba, clavePrueba);
    await sincronizarFotografos();
    await sincronizarAgenda();
    final previa = liquidacionesEntre(DateTime(2026, 10), DateTime(2026, 10, 15));
    expect(previa.single.fotografo.nombre, 'Ana López');
    expect(previa.single.sesiones.single.cliente, 'Larry Sánchez');
    expect(previa.single.comision, 60000);
    expect(pendientesEntre(DateTime(2026, 10), DateTime(2026, 10, 15)), (canceladas: 1, pendientes: 1));
  });
}
