import 'package:flutter/foundation.dart';

import '../core/reloj.dart';
import '../models/reserva/reserva_request.dart';
import '../models/sesion.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/api_service.dart';
import '../services/remote/reservas_api.dart';
import '../utils/formato.dart';
import 'mock_clientes.dart';
import 'mock_inasistencias.dart';
import 'mock_servicios.dart';

DateTime diaHabil(int dias, [int hora = 0, int minuto = 0]) {
  final d = Reloj.dia(dias, hora, minuto);
  if (d.weekday != DateTime.sunday) return d;
  return Reloj.dia(dias + (dias < 0 ? -1 : 1), hora, minuto);
}

SesionEstado estadoSegunReloj(DateTime inicio, int duracionMin) =>
    inicio.add(Duration(minutes: duracionMin)).isAfter(Reloj.ahora()) ? SesionEstado.programada : SesionEstado.realizada;

final List<Sesion> _ejemplo = _sembrar();

final List<Sesion> sesionesAgenda = [..._ejemplo];

final revisionAgenda = ValueNotifier(0);

const _diasAtras = 120;
const _diasAdelante = 180;

void _marcarDestacada(List<Sesion> sesiones) {
  final ahora = Reloj.ahora();
  final hoy = sesiones.where((s) => mismoDia(s.inicio, ahora) && s.estado == SesionEstado.programada && s.fin.isAfter(ahora)).toList()
    ..sort((a, b) => a.inicio.compareTo(b.inicio));
  if (hoy.isEmpty) return;
  final i = sesiones.indexOf(hoy.first);
  sesiones[i] = hoy.first.copyWith(destacada: true);
}

Future<void> sincronizarAgenda() async {
  if (!SesionActual.conectada) return;
  String nombreCliente(int? id) => clientes.where((c) => c.id != null && c.id == id).firstOrNull?.nombre ?? 'Cliente';
  ({String nombre, int duracion, int precio})? servicioPorId(int? id) {
    final s = serviciosEstudio.where((s) => s.id != null && s.id == id).firstOrNull;
    return s == null ? null : (nombre: s.nombre, duracion: s.duracionMin, precio: s.precio);
  }

  final sesiones = await ReservasApi().listar(
    desde: Reloj.dia(-_diasAtras),
    hasta: Reloj.dia(_diasAdelante),
    nombreCliente: nombreCliente,
    servicioPorId: servicioPorId,
  );
  _marcarDestacada(sesiones);
  sesionesAgenda
    ..clear()
    ..addAll(sesiones);
  revisionAgenda.value++;
}

Future<Sesion> crearReserva({
  required DateTime inicio,
  required String cliente,
  required int? clienteId,
  required String servicio,
  required int? servicioId,
  required int duracionMin,
  required int precio,
  required String fotografo,
}) async {
  Sesion nueva = Sesion(
    inicio: inicio,
    duracionMin: duracionMin,
    lugar: 'Estudio',
    cliente: cliente,
    descripcion: servicio,
    servicio: servicio,
    fotografo: fotografo,
    precio: precio,
    estado: SesionEstado.programada,
    clienteId: clienteId,
    servicioId: servicioId,
  );
  if (SesionActual.conectada) {
    if (clienteId == null || servicioId == null) {
      throw const ApiException('El cliente y el servicio deben estar registrados en el sistema.');
    }
    final deLaApi = await ReservasApi().crear(
      CrearReservaRequest(fecha: inicio, servicioId: servicioId, clienteId: clienteId),
      nombreCliente: (_) => cliente,
      servicioPorId: (_) => (nombre: servicio, duracion: duracionMin, precio: precio),
    );
    nueva = deLaApi.copyWith(fotografo: deLaApi.fotografo == 'Por asignar' ? fotografo : null);
  }
  sesionesAgenda.add(nueva);
  revisionAgenda.value++;
  return nueva;
}

Future<Sesion> reagendarSesion(Sesion sesion, DateTime inicio, {String? fotografo}) async {
  if (SesionActual.conectada && sesion.id != null && sesion.servicioId != null) {
    await ReservasApi().actualizar(
      sesion.id!,
      EditarReservaRequest(fecha: inicio, servicioId: sesion.servicioId!),
    );
  }
  final nueva = sesion.copyWith(
    inicio: inicio,
    fotografo: fotografo,
    estado: SesionEstado.programada,
    destacada: false,
  );
  final i = sesionesAgenda.indexWhere((s) => identical(s, sesion));
  if (i >= 0) sesionesAgenda[i] = nueva;
  revisionAgenda.value++;
  return nueva;
}

Future<Sesion> cancelarSesion(Sesion sesion, String motivo) async {
  if (SesionActual.conectada && sesion.id != null) await ReservasApi().cancelar(sesion.id!);
  final cancelada = sesion.copyWith(estado: SesionEstado.cancelada, destacada: false, motivo: 'Motivo: $motivo');
  final i = sesionesAgenda.indexWhere((s) => identical(s, sesion));
  if (i >= 0) sesionesAgenda[i] = cancelada;
  revisionAgenda.value++;
  return cancelada;
}

Future<List<DateTime>> horariosDisponibles(DateTime dia, int servicioId, {int? profesionalId}) async {
  return ReservasApi().consultarHorarios(dia, servicioId, profesionalId: profesionalId);
}

List<Sesion> programadasDeHoy([List<Sesion>? sesiones]) => (sesiones ?? sesionesAgenda)
    .where((s) => mismoDia(s.inicio, Reloj.hoy) && s.estado == SesionEstado.programada)
    .toList();

List<Sesion> _sembrar() {
  final anio = Reloj.hoy.year;
  Sesion hoy({
    required int hora,
    int minuto = 0,
    required int duracionMin,
    required String lugar,
    required String cliente,
    required String descripcion,
    String? servicio,
    required String fotografo,
    required String pago,
    required int precio,
    String? codigo,
    bool destacada = false,
  }) {
    final inicio = Reloj.dia(0, hora, minuto);
    return Sesion(
      inicio: inicio,
      duracionMin: duracionMin,
      lugar: lugar,
      cliente: cliente,
      descripcion: descripcion,
      servicio: servicio,
      fotografo: fotografo,
      pago: pago,
      precio: precio,
      estado: estadoSegunReloj(inicio, duracionMin),
      codigo: codigo,
      destacada: destacada,
    );
  }

  final deHoy = [
    hoy(
      hora: 8,
      minuto: 30,
      duracionMin: 60,
      lugar: 'Estudio A',
      cliente: 'Daniel Castro',
      descripcion: 'Sesión de graduación individual',
      servicio: 'Sesión de graduación',
      fotografo: 'Laura Méndez',
      pago: 'Efectivo',
      precio: 150000,
    ),
    hoy(
      hora: 10,
      duracionMin: 45,
      lugar: 'Ciclorama Blanco',
      cliente: 'Valentina Ruiz',
      descripcion: 'Retrato profesional corporativo (LinkedIn & Prensa)',
      servicio: 'Retrato profesional',
      fotografo: 'Laura Méndez',
      pago: 'Transferencia',
      precio: 120000,
      codigo: '#RSV-$anio-042',
    ),
    hoy(
      hora: 11,
      minuto: 30,
      duracionMin: 60,
      lugar: 'Set Principal',
      cliente: 'Andrés Molina',
      descripcion: 'Sesión familiar (4 integrantes + mascota)',
      servicio: 'Sesión familiar',
      fotografo: 'Mateo Ríos',
      pago: 'Transferencia',
      precio: 180000,
    ),
    hoy(
      hora: 14,
      duracionMin: 90,
      lugar: 'Mesa de Producto',
      cliente: 'Camila Pérez',
      descripcion: 'Fotografía de producto básica (Línea Cosmética)',
      servicio: 'Fotografía de producto básica',
      fotografo: 'Sara Torres',
      pago: 'Efectivo',
      precio: 250000,
    ),
  ];

  final i = deHoy.indexWhere((s) => s.estado == SesionEstado.programada);
  if (i >= 0) deHoy[i] = deHoy[i].copyWith(destacada: true);

  return [
    ...deHoy,
    Sesion(
      inicio: Reloj.dia(0, 16, 30),
      duracionMin: 120,
      lugar: 'Locación Externa',
      cliente: 'Sesión editorial - Cancelada por cliente',
      descripcion: '',
      fotografo: 'Nicolás Vega',
      estado: SesionEstado.cancelada,
      motivo: 'Motivo: Reprogramación por viaje',
    ),
    Sesion(
      inicio: diaHabil(-1, 9),
      duracionMin: 45,
      lugar: 'Ciclorama Blanco',
      cliente: 'Juliana Rojas',
      descripcion: 'Retrato profesional',
      fotografo: 'Laura Méndez',
      pago: 'Transferencia',
      precio: 120000,
      estado: SesionEstado.realizada,
    ),
    Sesion(
      inicio: diaHabil(-1, 15),
      duracionMin: 90,
      lugar: 'Mesa de Producto',
      cliente: 'Tienda Aurora',
      descripcion: 'Fotografía de producto e-commerce',
      fotografo: 'Sara Torres',
      pago: 'Efectivo',
      precio: 280000,
      estado: SesionEstado.realizada,
    ),
    Sesion(
      inicio: diaHabil(2, 9, 30),
      duracionMin: 90,
      lugar: 'Set Principal',
      cliente: 'Familia Ortiz',
      descripcion: 'Sesión familiar en estudio',
      fotografo: 'Mateo Ríos',
      pago: 'Transferencia',
      precio: 220000,
      estado: SesionEstado.programada,
    ),
    Sesion(
      inicio: diaHabil(2, 11, 30),
      duracionMin: 180,
      lugar: 'Locación Externa',
      cliente: 'Revista Lumen',
      descripcion: 'Editorial de moda',
      fotografo: 'Nicolás Vega',
      pago: 'Transferencia',
      precio: 450000,
      estado: SesionEstado.programada,
    ),
    ..._sesionesDeEjemplo(),
  ];
}

const _diasDeHistoria = 120;

const _plantillas = [
  ('Retrato profesional', 'Retrato profesional', 'Ciclorama Blanco', 45, 120000, 'Laura Méndez'),
  ('Sesión familiar en estudio', 'Sesión familiar en estudio', 'Set Principal', 90, 220000, 'Mateo Ríos'),
  ('Fotografía de producto e-commerce', 'Fotografía de producto e-commerce', 'Mesa de Producto', 90, 280000, 'Sara Torres'),
  ('Sesión de graduación individual', 'Sesión de graduación individual', 'Estudio A', 60, 150000, 'Laura Méndez'),
  ('Editorial de moda', 'Editorial de moda en locación', 'Locación Externa', 180, 450000, 'Nicolás Vega'),
];

const _clientesEjemplo = [
  'Familia Gómez', 'Sofía Herrera', 'Tienda Nativa', 'Martín Salazar', 'Laura Cifuentes',
  'Colegio San José', 'Estudio Bambú', 'Paula Ríos', 'Felipe Ardila', 'Revista Norte',
];

const _horas = [(9, 0), (11, 0), (14, 30), (16, 0)];

List<Sesion> _sesionesDeEjemplo() {
  final fijos = [diaHabil(-1), Reloj.hoy, diaHabil(2)];
  final sesiones = <Sesion>[];
  for (var n = -_diasDeHistoria; n <= _diasDeHistoria; n++) {
    final dia = Reloj.dia(n);
    if (dia.weekday == DateTime.sunday || fijos.any((f) => mismoDia(f, dia))) continue;
    final semilla = dia.difference(DateTime(2020)).inDays;
    final cuantas = const [0, 1, 2, 1, 3, 2, 1][semilla % 7];
    for (var k = 0; k < cuantas; k++) {
      final (servicio, descripcion, lugar, duracion, precio, fotografo) = _plantillas[(semilla + k * 2) % _plantillas.length];
      if (inasistencias.any((i) => i.fotografo == fotografo && i.cubre(dia))) continue;
      final (hora, minuto) = _horas[(k + semilla) % _horas.length];
      final pasada = dia.isBefore(Reloj.hoy);
      final cancelada = (semilla + k) % 11 == 0;
      sesiones.add(Sesion(
        inicio: Reloj.dia(n, hora, minuto),
        duracionMin: duracion,
        lugar: lugar,
        cliente: _clientesEjemplo[(semilla * 3 + k) % _clientesEjemplo.length],
        descripcion: descripcion,
        servicio: servicio,
        fotografo: fotografo,
        pago: semilla.isEven ? 'Transferencia' : 'Efectivo',
        precio: precio,
        estado: cancelada
            ? SesionEstado.cancelada
            : (pasada ? SesionEstado.realizada : SesionEstado.programada),
        motivo: cancelada ? 'Motivo: Reprogramación del cliente' : null,
      ));
    }
  }
  return sesiones;
}

final diasConAlertaAgenda = {diaHabil(2)};

const staffAgenda = [
  ('Laura M.', 'Laura Méndez'),
  ('Mateo R.', 'Mateo Ríos'),
  ('Sara T.', 'Sara Torres'),
  ('Nicolás V.', 'Nicolás Vega'),
];

Sesion get sesionEnGestion {
  final ahora = Reloj.ahora();
  final proximas = sesionesAgenda.where((s) => s.estado == SesionEstado.programada && s.fin.isAfter(ahora)).toList()
    ..sort((a, b) => a.inicio.compareTo(b.inicio));
  return sesionesAgenda.where((s) => s.destacada).firstOrNull ??
      proximas.firstOrNull ??
      _ejemplo.firstWhere((s) => s.cliente == 'Valentina Ruiz');
}

Sesion marcarRealizada(Sesion sesion) {
  final realizada = sesion.copyWith(estado: SesionEstado.realizada, destacada: false);
  final i = sesionesAgenda.indexWhere((s) => identical(s, sesion));
  if (i >= 0) sesionesAgenda[i] = realizada;
  revisionAgenda.value++;
  return realizada;
}
