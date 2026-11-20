import 'package:flutter/foundation.dart';

import '../core/reloj.dart';
import '../models/cierre.dart';
import '../models/common/json_utils.dart';
import '../models/fotografo.dart';
import '../models/liquidacion.dart';
import '../models/liquidacion/liquidacion_request.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/comisiones_api.dart';
import 'mock_agenda.dart';
import 'mock_fotografos.dart';

export '../models/cierre.dart' show codigoCierre;

final _q1 = ultimaQuincenaCerrable(Reloj.hoy);
final _q2 = quincenaAnterior(_q1.inicio);

DateTime _dia(int n) => _q1.inicio.add(Duration(days: n - 1));

String _rsv(int n) => '#RSV-${_q1.inicio.year}-${n.toString().padLeft(3, '0')}';

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

final List<Cierre> cierres = [..._ejemplo];

final revisionCierres = ValueNotifier(0);

Future<void> sincronizarCierres() async {
  if (!SesionActual.conectada) return;
  final deLaApi = await ComisionesApi().listarLiquidaciones()
    ..sort((a, b) => b.inicio.compareTo(a.inicio));
  cierres
    ..clear()
    ..addAll(deLaApi);
  revisionCierres.value++;
}

Future<Cierre> generarCierre(DateTime inicio, DateTime fin) async {
  final Cierre nuevo;
  if (SesionActual.conectada) {
    final request = LiquidacionRequest(fechaInicio: inicio, fechaFin: fin);
    nuevo = await ComisionesApi().crearLiquidacion(request);
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

List<Liquidacion> liquidacionesEntre(DateTime inicio, DateTime fin) {
  if (!SesionActual.conectada) {
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

({int canceladas, int pendientes}) pendientesEntre(DateTime inicio, DateTime fin) {
  final hasta = DateTime(fin.year, fin.month, fin.day + 1);
  final ahora = Reloj.ahora();
  final delRango = sesionesAgenda.where((s) => !s.inicio.isBefore(inicio) && s.inicio.isBefore(hasta));
  return (
    canceladas: delRango.where((s) => s.cancelada).length,
    pendientes: delRango.where((s) => !s.cancelada && s.fin.isAfter(ahora)).length,
  );
}

Future<List<Liquidacion>> liquidacionesDe(Cierre c) async {
  if (!SesionActual.conectada || c.id == null) return liquidacionesEntre(c.inicio, c.fin);
  final comisionesApi = ComisionesApi();
  final comisiones = await comisionesApi.listarComisiones(c.id!);
  return [
    for (final comision in comisiones)
      Liquidacion(
        fotografoDe(
          primerCampo(comision, ['profesional', 'profesionalNombre', 'nombreProfesional', 'profesionalId']),
          parseApiInt(primerCampo(comision, ['porcentaje', 'tasa'])),
        ),
        await _serviciosDe(comision, comisionesApi),
      ),
  ];
}

Future<List<SesionLiquidada>> _serviciosDe(Map comision, ComisionesApi comisionesApi) async {
  final incluidos = primerCampo(comision, ['servicios', 'reservas', 'detalle']);
  if (incluidos is List) return [for (final s in incluidos) if (s is Map) SesionLiquidada.fromJson(Map<String, dynamic>.from(s))];
  final id = parseApiInt(campo(comision, 'id'));
  if (id == null) return const [];
  return comisionesApi.listarServiciosDeComision(id);
}

Fotografo fotografoDe(Object? profesional, int? porcentaje) {
  final id = profesional is Map ? parseApiInt(campo(profesional, 'id')) : (profesional is int ? profesional : null);
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
