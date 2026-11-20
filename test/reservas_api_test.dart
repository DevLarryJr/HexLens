import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_movil/extensions/date_time_extensions.dart';
import 'package:proyecto_movil/data/mock_agenda.dart';
import 'package:proyecto_movil/data/mock_clientes.dart';
import 'package:proyecto_movil/data/mock_servicios.dart';
import 'package:proyecto_movil/models/sesion.dart';

import 'api_falsa.dart';

Future<void> conectar({List<Map<String, Object?>> reservas = const [], Object? horarios}) async {
  usarApiFalsa(
    clientes: [
      {'id': 1, 'documento': '1098765432', 'nombres': 'Larry', 'apellidos': 'Sánchez', 'celular': '3001234567'},
    ],
    servicios: [
      {'id': 7, 'nombre': 'Sesión de retrato', 'precio': 150000, 'descripcion': '10 fotos', 'duracion': 60, 'especialidad': 15},
    ],
    reservas: reservas,
    horarios: horarios ?? const ['09:00', '10:30', '14:00'],
  );
  await iniciarSesion(usuarioPrueba, clavePrueba);
  await sincronizarClientes();
  await sincronizarServicios();
  await sincronizarAgenda();
}

void main() {
  tearDown(SesionActual.cerrar);

  test('Formatos de fecha de la API', () {
    expect(DateTime(2026, 10, 30, 10).toIsoDateTimeString(), '2026-10-30T10:00:00');
    expect(fechaDesdeApi('2026-10-30 10:00:00'), DateTime(2026, 10, 30, 10));
    expect(fechaDesdeApi('2026-10-30T14:30:00Z'), DateTime(2026, 10, 30, 14, 30));
    expect(fechaDesdeApi('hola'), isNull);
    expect(estadoDesdeApi('Cancelada'), SesionEstado.cancelada);
    expect(estadoDesdeApi('ATENDIDA'), SesionEstado.realizada);
    expect(estadoDesdeApi('Pendiente'), SesionEstado.programada);
  });

  test('La agenda se llena con las reservas de la API (objetos anidados o solo ids)', () async {
    await conectar(reservas: [
      {
        'id': 12,
        'fecha': '2026-10-15T10:00:00',
        'estado': 'Confirmada',
        'cliente': {'id': 1, 'nombres': 'Larry', 'apellidos': 'Sánchez'},
        'servicio': {'id': 7, 'nombre': 'Sesión de retrato', 'duracion': 60, 'precio': 150000},
        'profesional': {'nombres': 'Ana', 'apellidos': 'López'},
      },
      {'Id': 13, 'Fecha': '2026-10-16 09:00:00', 'Estado': 'Cancelada', 'ClienteId': 1, 'ServicioId': 7},
    ]);
    expect(peticionesRecibidas.last.url.queryParameters.keys, containsAll(['FechaInicio', 'FechaFin']));
    expect(sesionesAgenda, hasLength(2));
    final primera = sesionesAgenda.first;
    expect(primera.id, 12);
    expect(primera.cliente, 'Larry Sánchez');
    expect(primera.nombreServicio, 'Sesión de retrato');
    expect(primera.fotografo, 'Ana López');
    expect(primera.inicio, DateTime(2026, 10, 15, 10));
    expect(primera.precio, 150000);
    final segunda = sesionesAgenda.last;
    expect(segunda.cliente, 'Larry Sánchez');
    expect(segunda.duracionMin, 60);
    expect(segunda.cancelada, isTrue);
  });

  test('Reserva con la forma real de la API: día en fecha y hora en horaInicio/horaFin', () async {
    await conectar(reservas: [
      {
        'id': 1,
        'fecha': '2026-10-23T00:00:00',
        'horaInicio': '08:30:00',
        'horaFin': '09:00:00',
        'clienteId': 1,
        'servicioId': 2,
        'profesionalId': 2,
        'estado': 0,
        'cliente': {'id': 1, 'nombres': 'Maria Fernanda', 'apellidos': 'Garcia Lopez'},
        'servicio': {'id': 2, 'nombre': 'Limpieza Facial', 'precio': 20000},
        'profesional': {'id': 2, 'nombres': 'Ana', 'apellidos': 'Lopez'},
      },
    ]);
    final sesion = sesionesAgenda.single;
    expect(sesion.inicio, DateTime(2026, 10, 23, 8, 30));
    expect(sesion.duracionMin, 30);
    expect(sesion.cliente, 'Maria Fernanda Garcia Lopez');
    expect(sesion.fotografo, 'Ana Lopez');
    expect(sesion.precio, 20000);
    expect(sesion.cancelada, isFalse);
  });

  test('Crear, reagendar y cancelar una reserva con la API', () async {
    await conectar();
    final reserva = await crearReserva(
      inicio: DateTime(2026, 10, 30, 10),
      cliente: clientes.single.nombre,
      clienteId: clientes.single.id,
      servicio: serviciosEstudio.single.nombre,
      servicioId: serviciosEstudio.single.id,
      duracionMin: 60,
      precio: 150000,
      fotografo: 'Por asignar',
    );
    expect(jsonDecode(peticionesRecibidas.last.body), {'Fecha': '2026-10-30T10:00:00', 'ServicioId': 7, 'ClienteId': 1});
    expect(reserva.id, 400);
    expect(sesionesAgenda.last, same(reserva));

    final movida = await reagendarSesion(reserva, DateTime(2026, 11, 3, 14));
    expect(peticionesRecibidas.last.method, 'PUT');
    expect(peticionesRecibidas.last.url.path, '/api/reservas/400');
    expect(jsonDecode(peticionesRecibidas.last.body), {'Fecha': '2026-11-03T14:00:00', 'ServicioId': 7});

    final cancelada = await cancelarSesion(movida, 'Cliente reprograma');
    expect(peticionesRecibidas.last.method, 'DELETE');
    expect(cancelada.cancelada, isTrue);
    expect(sesionesAgenda.last, same(cancelada));
  });

  test('Sin cliente registrado en la API no se puede reservar', () async {
    await conectar();
    await expectLater(
      crearReserva(
        inicio: DateTime(2026, 10, 30, 10),
        cliente: 'Valentina Ruiz',
        clienteId: null,
        servicio: 'Retrato',
        servicioId: 7,
        duracionMin: 45,
        precio: 120000,
        fotografo: 'Por asignar',
      ),
      throwsA(isA<ApiException>()),
    );
  });

  test('Horarios disponibles: lista de horas o de objetos', () async {
    await conectar();
    expect(await horariosDisponibles(DateTime(2026, 10, 30), 7),
        [DateTime(2026, 10, 30, 9), DateTime(2026, 10, 30, 10, 30), DateTime(2026, 10, 30, 14)]);
    expect(peticionesRecibidas.last.url.query, 'fecha=2026-10-30&servicioId=7');

    await conectar(horarios: [
      {'horaInicio': '2026-10-30T16:00:00', 'profesional': 'Ana'},
      {'hora': '08:30'},
    ]);
    expect(await horariosDisponibles(DateTime(2026, 10, 30), 7), [DateTime(2026, 10, 30, 8, 30), DateTime(2026, 10, 30, 16)]);
  });

  test('Horarios por profesional: agrega profesionalId a la consulta', () async {
    await conectar();
    await horariosDisponibles(DateTime(2026, 10, 20), 58, profesionalId: 17);
    expect(peticionesRecibidas.last.url.query, 'fecha=2026-10-20&servicioId=58&profesionalId=17');
  });
}
