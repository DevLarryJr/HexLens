import 'package:flutter/foundation.dart';

import '../api/api.dart';
import '../api/comisiones_api.dart';
import '../core/reloj.dart';
import '../models/cierre.dart';
import '../models/fotografo.dart';
import '../models/liquidacion.dart';
import 'mock_agenda.dart';
import 'mock_fotografos.dart';

export '../api/comisiones_api.dart' show codigoCierre;

/// Última quincena terminada (la del cierre más reciente) y la anterior a ella.
final _q1 = ultimaQuincenaCerrable(Reloj.hoy);
final _q2 = quincenaAnterior(_q1.inicio);

/// Día [n] de la quincena del cierre más reciente (1 = su primer día).
DateTime _dia(int n) => _q1.inicio.add(Duration(days: n - 1));

String _rsv(int n) => '#RSV-${_q1.inicio.year}-${n.toString().padLeft(3, '0')}';

/// Liquidación del cierre más reciente: sesiones realizadas de la última quincena terminada.
final liquidacionesUltimoCierre = [
  Liquidacion(fotografoEjemplo('Laura Méndez'), [
    SesionLiquidada('Valentina Ruiz', _rsv(36), 'Retrato Profesional', _dia(15), 120000),
    SesionLiquidada('Daniel Castro', _rsv(38), 'Graduación Individual', _dia(15), 150000),
    SesionLiquidada('Elena Gómez', _rsv(29), 'Retrato Corporativo', _dia(8), 130000),
    SesionLiquidada('Carlos Mendoza', _rsv(15), 'Retrato Profesional', _dia(3), 120000),
  ]),
  Liquidacion(fotografoEjemplo('Mateo Ríos'), [
    SesionLiquidada('Andrés Molina', _rsv(40), 'Sesión Familiar', _dia(15), 180000),
    SesionLiquidada('Familia Rojas', _rsv(21), 'Sesión Familiar', _dia(6), 180000),
  ]),
  Liquidacion(fotografoEjemplo('Sara Torres'), [
    SesionLiquidada('Camila Pérez', _rsv(41), 'Producto Básica', _dia(15), 250000),
    SesionLiquidada('Aura Cosméticos', _rsv(18), 'Producto Básica', _dia(4), 70000),
  ]),
];

/// Cierres de ejemplo (sin sesión en la API), del más reciente al más antiguo.
final _ejemplo = [
  Cierre(
    codigo: codigoCierre(_q1.inicio),
    quincena: _q1.inicio.day == 1 ? 1 : 2,
    inicio: _q1.inicio,
    fin: _q1.fin,
    estado: EstadoCierre.auditado,
    servicios: liquidacionesUltimoCierre.fold(0, (a, l) => a + l.sesiones.length),
    total: liquidacionesUltimoCierre.fold(0, (a, l) => a + l.base),
    staff: liquidacionesUltimoCierre.fold(0, (a, l) => a + l.comision),
    fotografos: [for (final l in liquidacionesUltimoCierre) l.fotografo.nombre],
  ),
  Cierre(
    codigo: codigoCierre(_q2.inicio),
    quincena: _q2.inicio.day == 1 ? 1 : 2,
    inicio: _q2.inicio,
    fin: _q2.fin,
    estado: EstadoCierre.liquidado,
    servicios: 12,
    total: 1850000,
    staff: 610000,
  ),
];


/// Cierres de período: las liquidaciones de la API si hay sesión, si no los de ejemplo (más reciente primero).
final List<Cierre> cierres = [..._ejemplo];

/// Cambia cada vez que se genera un cierre.
final revisionCierres = ValueNotifier(0);

/// Con sesión en la API, reemplaza los cierres por las liquidaciones de `GET /api/liquidaciones-comisiones`.
/// Lanza [ApiError] si falla.
Future<void> sincronizarCierres() async {
  if (!Api.conectada) return;
  final deLaApi = [for (final l in await obtenerLiquidacionesApi()) cierreDesdeApi(l)]
    ..sort((a, b) => b.inicio.compareTo(a.inicio));
  cierres
    ..clear()
    ..addAll(deLaApi);
  revisionCierres.value++;
}

/// Genera el cierre de [inicio] a [fin] (con sesión en la API: `POST /api/liquidaciones-comisiones`, que calcula
/// las comisiones) y lo pone primero en la lista.
Future<Cierre> generarCierre(DateTime inicio, DateTime fin) async {
  final Cierre nuevo;
  if (Api.conectada) {
    nuevo = cierreDesdeApi(await crearLiquidacionApi(inicio, fin));
  } else {
    final liquidaciones = liquidacionesEntre(inicio, fin);
    nuevo = Cierre(
      codigo: codigoCierre(inicio),
      quincena: inicio.day <= 15 ? 1 : 2,
      inicio: inicio,
      fin: fin,
      estado: EstadoCierre.auditado,
      servicios: liquidaciones.fold(0, (a, l) => a + l.sesiones.length),
      total: liquidaciones.fold(0, (a, l) => a + l.base),
      staff: liquidaciones.fold(0, (a, l) => a + l.comision),
      fotografos: [for (final l in liquidaciones) l.fotografo.nombre],
    );
  }
  cierres.insert(0, nuevo);
  revisionCierres.value++;
  return nuevo;
}

/// Vista previa de las comisiones entre [inicio] y [fin]: con la API, las sesiones ya terminadas y no canceladas
/// de la agenda, agrupadas por fotógrafo con su porcentaje (la API calcula el valor definitivo al generar el
/// cierre); sin ella, las del cierre de ejemplo.
List<Liquidacion> liquidacionesEntre(DateTime inicio, DateTime fin) {
  if (!Api.conectada) {
    return [
      for (final l in liquidacionesUltimoCierre)
        if (l.entre(inicio, fin).sesiones.isNotEmpty) l.entre(inicio, fin),
    ];
  }
  final hasta = DateTime(fin.year, fin.month, fin.day + 1);
  final ahora = Reloj.ahora();
  final porFotografo = <String, List<SesionLiquidada>>{};
  for (final s in sesionesAgenda) {
    if (s.cancelada || s.inicio.isBefore(inicio) || !s.inicio.isBefore(hasta) || s.fin.isAfter(ahora)) continue;
    porFotografo.putIfAbsent(s.fotografo, () => []).add(
          SesionLiquidada(s.cliente, s.codigo ?? '', s.nombreServicio, s.inicio, s.precio ?? 0),
        );
  }
  return [for (final e in porFotografo.entries) Liquidacion(fotografoDe(e.key, null), e.value)];
}

/// Cuántas sesiones del rango están canceladas y cuántas siguen programadas (aún no terminan).
({int canceladas, int pendientes}) pendientesEntre(DateTime inicio, DateTime fin) {
  final hasta = DateTime(fin.year, fin.month, fin.day + 1);
  final ahora = Reloj.ahora();
  final delRango = sesionesAgenda.where((s) => !s.inicio.isBefore(inicio) && s.inicio.isBefore(hasta));
  return (
    canceladas: delRango.where((s) => s.cancelada).length,
    pendientes: delRango.where((s) => !s.cancelada && s.fin.isAfter(ahora)).length,
  );
}

/// Comisiones por fotógrafo de [c]: con la API, las de `GET /api/comisiones?cierreId=`; sin ella, las de ejemplo.
Future<List<Liquidacion>> liquidacionesDe(Cierre c) async {
  if (Api.conectada && c.id != null) return obtenerComisionesApi(c.id!, fotografoDe: fotografoDe);
  return liquidacionesEntre(c.inicio, c.fin);
}

/// Fotógrafo del staff a partir de lo que mande la API (objeto, nombre o id); si no está en el staff, uno con
/// ese nombre y el [porcentaje] dado.
Fotografo fotografoDe(Object? profesional, int? porcentaje) {
  final id = profesional is Map ? entero(campo(profesional, 'id')) : (profesional is int ? profesional : null);
  final nombre = profesional is int ? '' : nombreDe(profesional);
  final delStaff = fotografos.where((f) => (id != null && f.id == id) || (nombre.isNotEmpty && f.nombre == nombre)).firstOrNull;
  if (delStaff != null) return delStaff;
  return Fotografo(
    nombre: nombre.isEmpty ? 'Profesional' : nombre,
    documento: '',
    especialidad: '',
    comisionPct: porcentaje ?? 0,
    estado: EstadoFotografo.disponible,
  );
}
