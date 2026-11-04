import 'package:flutter/foundation.dart';

import '../api/api.dart';
import '../api/profesionales_api.dart';
import '../core/reloj.dart';
import '../models/especialidad.dart';
import '../models/fotografo.dart';
import '../models/servicio.dart';
import '../utils/formato.dart';
import 'mock_especialidades.dart';
import 'mock_inasistencias.dart';

/// Fotógrafos de ejemplo (sin sesión en la API). Los cierres y comisiones de ejemplo usan estos.
const fotografosEjemplo = [
  Fotografo(
    nombre: 'Laura Méndez',
    documento: 'C.C. 52.890.123',
    foto: 'foto_laura_staff.jpg',
    especialidad: 'Retratos',
    score: 4.9,
    comisionPct: 30,
    equipo: 'Sony A7R V + 85mm f/1.4 GM',
    estado: EstadoFotografo.enTurno,
  ),
  Fotografo(
    nombre: 'Mateo Ríos',
    documento: 'C.C. 80.124.567',
    foto: 'foto_mateo.jpg',
    especialidad: 'Familiar',
    score: 4.8,
    comisionPct: 35,
    equipo: 'Canon R5 + 24-70mm f/2.8',
    estado: EstadoFotografo.disponible,
  ),
  Fotografo(
    nombre: 'Sara Torres',
    documento: 'C.C. 53.441.980',
    foto: 'foto_sara.jpg',
    especialidad: 'Productos',
    score: 4.9,
    comisionPct: 30,
    equipo: 'Nikon Z7 II + 105mm Macro',
    estado: EstadoFotografo.almuerzo,
  ),
  Fotografo(
    nombre: 'Nicolás Vega',
    documento: 'C.C. 79.991.234',
    foto: 'foto_nicolas_staff.jpg',
    especialidad: 'Editorial',
    comisionPct: 40,
    equipo: 'Sin equipo en custodia',
    estado: EstadoFotografo.inactivo,
  ),
];

/// Staff de fotógrafos del estudio: los de la API si hay sesión, si no los de ejemplo.
final List<Fotografo> fotografos = [...fotografosEjemplo];

/// Cambia cada vez que se registra o modifica un fotógrafo.
final revisionFotografos = ValueNotifier(0);

/// Fotógrafos por id de especialidad ya consultados a la API; se borra cuando cambia el staff.
final _porEspecialidad = <int, List<Fotografo>>{};

void _avisar() {
  _porEspecialidad.clear();
  revisionFotografos.value++;
}

/// Fotógrafos activos que pueden atender un servicio de [servicio]: con la API, los de
/// `GET /api/profesionales/{id}/especialiades` (si la API responde 404, los del staff ya cargado);
/// sin la API, los del staff local.
Future<List<Fotografo>> fotografosParaServicio(Servicio servicio) async {
  final id = servicio.especialidadId;
  List<Fotografo> delStaff() => [
        for (final f in fotografos)
          if (f.activo && (id != null ? f.especialidadId == id : f.especialidad == servicio.categoria)) f,
      ];
  if (!Api.conectada || id == null) return delStaff();
  final consultados = _porEspecialidad[id];
  if (consultados != null) return consultados;
  try {
    final json = await profesionalesPorEspecialidadApi(id);
    return _porEspecialidad[id] = [
      for (final p in json) fotografoDesdeApi(p, nombreEspecialidad: nombreEspecialidad),
    ].where((f) => f.activo).toList();
  } on ApiError catch (e) {
    if (e.estado != 404) rethrow;
    return delStaff();
  }
}

/// Fotógrafo que se muestra en una reserva de [servicio]: el primero de [fotografosParaServicio], o null si no
/// hay o la API no respondió. Solo es informativo: la reserva no lo envía y la API asigna el definitivo.
Future<Fotografo?> fotografoSugerido(Servicio servicio) async {
  try {
    return (await fotografosParaServicio(servicio)).firstOrNull;
  } on ApiError {
    return null;
  }
}

/// Fotógrafo por nombre, o null si no está en el staff.
Fotografo? fotografoPorNombre(String nombre) {
  for (final f in fotografos) {
    if (f.nombre == nombre) return f;
  }
  return null;
}

/// Fotógrafo de ejemplo por nombre (para los datos de ejemplo que no vienen de la API, como los cierres).
Fotografo fotografoEjemplo(String nombre) => fotografosEjemplo.firstWhere((f) => f.nombre == nombre);

/// Con sesión en la API, reemplaza el staff por los profesionales de `GET /api/profesionales`.
/// Lanza [ApiError] si falla.
Future<void> sincronizarFotografos() async {
  if (!Api.conectada) return;
  final deLaApi = await obtenerProfesionalesApi();
  fotografos
    ..clear()
    ..addAll([for (final p in deLaApi) fotografoDesdeApi(p, nombreEspecialidad: nombreEspecialidad)]);
  _avisar();
}

/// Registra un profesional (en la API si hay sesión) y lo agrega al staff.
Future<Fotografo> registrarFotografo({
  required String documento,
  required String nombres,
  required String apellidos,
  required DateTime nacimiento,
  required int comisionPct,
  required bool activo,
  required Especialidad especialidad,
}) async {
  final Fotografo nuevo;
  if (Api.conectada) {
    final json = await crearProfesionalApi(profesionalParaApi(
      documento: documento,
      nombres: nombres,
      apellidos: apellidos,
      nacimiento: nacimiento,
      porcentaje: comisionPct,
      activo: activo,
      especialidadId: especialidad.id ?? 0,
    ));
    nuevo = fotografoDesdeApi(json, nombreEspecialidad: nombreEspecialidad);
  } else {
    nuevo = Fotografo(
      nombre: '${nombres.trim()} ${apellidos.trim()}'.trim(),
      nombres: nombres.trim(),
      apellidos: apellidos.trim(),
      documento: 'C.C. ${milesConPunto(soloDigitos(documento))}',
      especialidad: especialidad.nombre,
      comisionPct: comisionPct,
      estado: activo ? EstadoFotografo.disponible : EstadoFotografo.inactivo,
    );
  }
  fotografos.add(nuevo);
  _avisar();
  return nuevo;
}

/// Reemplaza [f] por una copia con los cambios dados.
Fotografo _cambiar(Fotografo f, {String? nombres, String? apellidos, int? comisionPct, Especialidad? especialidad, EstadoFotografo? estado}) {
  final nuevosNombres = nombres ?? f.nombres;
  final nuevosApellidos = apellidos ?? f.apellidos;
  final copia = Fotografo(
    id: f.id,
    nombre: nombres == null && apellidos == null
        ? f.nombre
        : [nuevosNombres ?? '', nuevosApellidos ?? ''].where((p) => p.isNotEmpty).join(' '),
    nombres: nuevosNombres,
    apellidos: nuevosApellidos,
    documento: f.documento,
    foto: f.foto,
    especialidad: especialidad?.nombre ?? f.especialidad,
    especialidadId: especialidad?.id ?? f.especialidadId,
    comisionPct: comisionPct ?? f.comisionPct,
    equipo: f.equipo,
    score: f.score,
    estado: estado ?? f.estado,
  );
  final i = fotografos.indexOf(f);
  if (i >= 0) fotografos[i] = copia;
  _avisar();
  return copia;
}

/// Guarda nombre, comisión y especialidad de [f] (`PUT /api/profesionales/{id}` si hay sesión).
/// [nombreCompleto] se parte en nombres y apellidos: si termina con sus apellidos actuales, solo cambian los nombres.
Future<Fotografo> actualizarCondiciones(
  Fotografo f, {
  required String nombreCompleto,
  required int comisionPct,
  required Especialidad especialidad,
}) async {
  final limpio = nombreCompleto.trim().replaceAll(RegExp(r'\s+'), ' ');
  final apellidosActuales = f.apellidos ?? '';
  final String nombres;
  final String apellidos;
  if (apellidosActuales.isNotEmpty && limpio.endsWith(apellidosActuales)) {
    nombres = limpio.substring(0, limpio.length - apellidosActuales.length).trim();
    apellidos = apellidosActuales;
  } else {
    final partes = limpio.split(' ');
    nombres = partes.first;
    apellidos = partes.skip(1).join(' ');
  }
  if (Api.conectada && f.id != null) {
    await actualizarProfesionalApi(f.id!, {
      'Nombres': nombres,
      'Apellidos': apellidos,
      'Porcentaje': comisionPct,
      if (especialidad.id != null) 'Especialidad': especialidad.id,
    });
  }
  return _cambiar(f, nombres: nombres, apellidos: apellidos, comisionPct: comisionPct, especialidad: especialidad);
}

/// Activa o inactiva a [f] (`PUT /api/profesionales/{id}` con `{Estado}` si hay sesión). Al activarlo vuelve
/// a trabajar hoy: también se termina su ausencia vigente (licencia, permiso…), si tenía.
Future<Fotografo> cambiarEstadoFotografo(Fotografo f, {required bool activo}) async {
  if (Api.conectada && f.id != null) await actualizarProfesionalApi(f.id!, {'Estado': activo});
  if (activo) liberarAusencias(f.nombre, Reloj.hoy);
  return _cambiar(f, estado: activo ? EstadoFotografo.disponible : EstadoFotografo.inactivo);
}
