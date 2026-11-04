import 'package:flutter/foundation.dart';

import '../api/api.dart';
import '../api/reservas_api.dart';
import '../core/reloj.dart';
import '../models/sesion.dart';
import '../utils/formato.dart';
import 'mock_clientes.dart';
import 'mock_inasistencias.dart';
import 'mock_servicios.dart';

/// Día hábil a [dias] de hoy: si cae en domingo (estudio cerrado) se corre un día más en la misma dirección.
DateTime diaHabil(int dias, [int hora = 0, int minuto = 0]) {
  final d = Reloj.dia(dias, hora, minuto);
  if (d.weekday != DateTime.sunday) return d;
  return Reloj.dia(dias + (dias < 0 ? -1 : 1), hora, minuto);
}

/// Estado real de una sesión de hoy: realizada si ya terminó, programada si no.
SesionEstado estadoSegunReloj(DateTime inicio, int duracionMin) =>
    inicio.add(Duration(minutes: duracionMin)).isAfter(Reloj.ahora()) ? SesionEstado.programada : SesionEstado.realizada;

/// Sesiones de ejemplo, ancladas a la fecha real: ayer (realizadas), hoy (según la hora), pasado mañana
/// (programadas) y unos meses alrededor. La sesión en curso o próxima de hoy queda [Sesion.destacada].
final List<Sesion> _ejemplo = _sembrar();

/// Sesiones de la agenda operativa: las reservas de la API si hay sesión, si no las de ejemplo.
final List<Sesion> sesionesAgenda = [..._ejemplo];

/// Cambia cada vez que se modifica la agenda (p. ej. al reagendar), para que las pantallas abiertas se actualicen.
final revisionAgenda = ValueNotifier(0);

/// Días hacia atrás y hacia adelante de hoy que se piden a la API.
const _diasAtras = 120;
const _diasAdelante = 180;

/// Marca como destacada la primera sesión de hoy que todavía no termina.
void _marcarDestacada(List<Sesion> sesiones) {
  final ahora = Reloj.ahora();
  final hoy = sesiones.where((s) => mismoDia(s.inicio, ahora) && s.estado == SesionEstado.programada && s.fin.isAfter(ahora)).toList()
    ..sort((a, b) => a.inicio.compareTo(b.inicio));
  if (hoy.isEmpty) return;
  final i = sesiones.indexOf(hoy.first);
  sesiones[i] = hoy.first.copyWith(destacada: true);
}

/// Con sesión en la API, reemplaza la agenda por las reservas de `GET /api/reservas` (unos meses alrededor de
/// hoy). El cliente y el servicio que no vengan completos en la reserva se buscan por id en los ya cargados
/// (por eso conviene cargar antes clientes y servicios). Lanza [ApiError] si falla.
Future<void> sincronizarAgenda() async {
  if (!Api.conectada) return;
  final reservas = await obtenerReservasApi(Reloj.dia(-_diasAtras), Reloj.dia(_diasAdelante));
  String nombreCliente(int? id) => clientes.where((c) => c.id != null && c.id == id).firstOrNull?.nombre ?? 'Cliente';
  ({String nombre, int duracion, int precio})? servicioPorId(int? id) {
    final s = serviciosEstudio.where((s) => s.id != null && s.id == id).firstOrNull;
    return s == null ? null : (nombre: s.nombre, duracion: s.duracionMin, precio: s.precio);
  }

  final sesiones = [
    for (final r in reservas) sesionDesdeApi(r, nombreCliente: nombreCliente, servicioPorId: servicioPorId),
  ];
  _marcarDestacada(sesiones);
  sesionesAgenda
    ..clear()
    ..addAll(sesiones);
  revisionAgenda.value++;
}

/// Crea una reserva (en la API si hay sesión: `POST /api/reservas`) y la agrega a la agenda.
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
  if (Api.conectada) {
    if (clienteId == null || servicioId == null) {
      throw const ApiError('El cliente y el servicio deben estar registrados en el sistema.');
    }
    final json = await crearReservaApi(inicio: inicio, servicioId: servicioId, clienteId: clienteId);
    final deLaApi = sesionDesdeApi(json,
        nombreCliente: (_) => cliente, servicioPorId: (_) => (nombre: servicio, duracion: duracionMin, precio: precio));
    nueva = deLaApi.copyWith(fotografo: deLaApi.fotografo == 'Por asignar' ? fotografo : null);
  }
  sesionesAgenda.add(nueva);
  revisionAgenda.value++;
  return nueva;
}

/// Mueve [sesion] a [inicio] con el fotógrafo [fotografo] y devuelve la sesión reagendada (con sesión en la
/// API: `PUT /api/reservas/{id}`). Deja de ser la destacada de hoy, porque ya no ocurre en este momento.
Future<Sesion> reagendarSesion(Sesion sesion, DateTime inicio, {String? fotografo}) async {
  if (Api.conectada && sesion.id != null && sesion.servicioId != null) {
    await editarReservaApi(sesion.id!, inicio: inicio, servicioId: sesion.servicioId!);
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

/// Cancela [sesion] con el [motivo] elegido (con sesión en la API: `DELETE /api/reservas/{id}`). Sigue en la
/// agenda, marcada como cancelada.
Future<Sesion> cancelarSesion(Sesion sesion, String motivo) async {
  if (Api.conectada && sesion.id != null) await cancelarReservaApi(sesion.id!);
  final cancelada = sesion.copyWith(estado: SesionEstado.cancelada, destacada: false, motivo: 'Motivo: $motivo');
  final i = sesionesAgenda.indexWhere((s) => identical(s, sesion));
  if (i >= 0) sesionesAgenda[i] = cancelada;
  revisionAgenda.value++;
  return cancelada;
}

/// Sesiones de hoy que siguen programadas, de [sesiones] o de la agenda del estudio.
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

  // La primera de hoy que aún no termina es la "en curso o próxima".
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

/// Días alrededor de hoy que se llenan con sesiones de ejemplo (unos 4 meses hacia atrás y hacia adelante).
const _diasDeHistoria = 120;

/// Sesiones de ejemplo: (servicio, descripción, lugar, duración, precio, fotógrafo).
const _plantillas = [
  ('Retrato profesional', 'Retrato profesional', 'Ciclorama Blanco', 45, 120000, 'Laura Méndez'),
  ('Sesión familiar en estudio', 'Sesión familiar en estudio', 'Set Principal', 90, 220000, 'Mateo Ríos'),
  ('Fotografía de producto e-commerce', 'Fotografía de producto e-commerce', 'Mesa de Producto', 90, 280000, 'Sara Torres'),
  ('Sesión de graduación individual', 'Sesión de graduación individual', 'Estudio A', 60, 150000, 'Laura Méndez'),
  ('Editorial de moda', 'Editorial de moda en locación', 'Locación Externa', 180, 450000, 'Nicolás Vega'),
];

/// Clientes de las sesiones de ejemplo (no están en el directorio, así no cambian sus fichas).
const _clientesEjemplo = [
  'Familia Gómez', 'Sofía Herrera', 'Tienda Nativa', 'Martín Salazar', 'Laura Cifuentes',
  'Colegio San José', 'Estudio Bambú', 'Paula Ríos', 'Felipe Ardila', 'Revista Norte',
];

/// Horas de inicio posibles de las sesiones de ejemplo.
const _horas = [(9, 0), (11, 0), (14, 30), (16, 0)];

/// Sesiones de ejemplo para los días alrededor de hoy (menos ayer, hoy y pasado mañana, que ya tienen las suyas,
/// y sin fotógrafos en sus días de ausencia),
/// para que la agenda, el calendario mensual y las semanas siguientes tengan datos. Son siempre las mismas para
/// cada fecha (no dependen de cuándo se abra la app); las pasadas salen realizadas y las futuras, programadas.
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
      // El estudio no agenda a un fotógrafo en los días de su ausencia registrada.
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

/// Días con alerta operativa (sobrecupo): sus puntos salen en rojo.
final diasConAlertaAgenda = {diaHabil(2)};

/// Fotógrafos del filtro de staff: etiqueta corta → nombre completo.
const staffAgenda = [
  ('Laura M.', 'Laura Méndez'),
  ('Mateo R.', 'Mateo Ríos'),
  ('Sara T.', 'Sara Torres'),
  ('Nicolás V.', 'Nicolás Vega'),
];

/// Sesión que se gestiona desde el detalle: la en curso o próxima de hoy; si hoy ya no queda ninguna,
/// la próxima programada; y si no hay, la de Valentina Ruiz (de ejemplo).
Sesion get sesionEnGestion {
  final ahora = Reloj.ahora();
  final proximas = sesionesAgenda.where((s) => s.estado == SesionEstado.programada && s.fin.isAfter(ahora)).toList()
    ..sort((a, b) => a.inicio.compareTo(b.inicio));
  return sesionesAgenda.where((s) => s.destacada).firstOrNull ??
      proximas.firstOrNull ??
      _ejemplo.firstWhere((s) => s.cliente == 'Valentina Ruiz');
}

/// Marca [sesion] como realizada. Solo en la app: la API no tiene una acción para esto (se pierde al recargar
/// la agenda desde la API).
Sesion marcarRealizada(Sesion sesion) {
  final realizada = sesion.copyWith(estado: SesionEstado.realizada, destacada: false);
  final i = sesionesAgenda.indexWhere((s) => identical(s, sesion));
  if (i >= 0) sesionesAgenda[i] = realizada;
  revisionAgenda.value++;
  return realizada;
}
