import 'package:flutter/foundation.dart';

import '../core/reloj.dart';
import '../models/especialidad.dart';
import '../models/fotografo.dart';
import '../models/profesional/profesional_request.dart';
import '../models/servicio.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/api_service.dart';
import '../services/remote/profesionales_api.dart';
import '../utils/formato.dart';
import 'mock_especialidades.dart';
import 'mock_inasistencias.dart';

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

final List<Fotografo> fotografos = [...fotografosEjemplo];

final revisionFotografos = ValueNotifier(0);

final _porServicio = <int, List<Fotografo>>{};

void _avisar() {
  _porServicio.clear();
  revisionFotografos.value++;
}

Future<List<Fotografo>> fotografosParaServicio(Servicio servicio) async {
  final especialidadId = servicio.especialidadId;
  List<Fotografo> delStaff() => [
        for (final f in fotografos)
          if (f.activo &&
              (especialidadId != null ? f.especialidadId == especialidadId : f.especialidad == servicio.categoria))
            f,
      ];
  final servicioId = servicio.id;
  if (!SesionActual.conectada || servicioId == null) return delStaff();
  final consultados = _porServicio[servicioId];
  if (consultados != null) return consultados;
  final List<Fotografo> deLaApi;
  try {
    deLaApi = await ProfesionalesApi().listarPorServicio(servicioId, nombreEspecialidad: nombreEspecialidad);
  } on ApiException catch (e) {
    if (e.isNotFound) return delStaff();
    rethrow;
  }
  return _porServicio[servicioId] = deLaApi.where((f) => f.activo).toList();
}

Future<Fotografo?> fotografoSugerido(Servicio servicio) async {
  try {
    return (await fotografosParaServicio(servicio)).firstOrNull;
  } on ApiException {
    return null;
  }
}

Fotografo? fotografoPorNombre(String nombre) {
  for (final f in fotografos) {
    if (f.nombre == nombre) return f;
  }
  return null;
}

Fotografo fotografoEjemplo(String nombre) => fotografosEjemplo.firstWhere((f) => f.nombre == nombre);

Future<void> sincronizarFotografos() async {
  if (!SesionActual.conectada) return;
  final deLaApi = await ProfesionalesApi().listar(nombreEspecialidad: nombreEspecialidad);
  fotografos
    ..clear()
    ..addAll(deLaApi);
  _avisar();
}

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
  if (SesionActual.conectada) {
    final request = CrearProfesionalRequest(
      documento: documento,
      nombres: nombres,
      apellidos: apellidos,
      fechaNacimiento: nacimiento,
      porcentaje: comisionPct,
      activo: activo,
      especialidadId: especialidad.id ?? 0,
    );
    nuevo = await ProfesionalesApi().crear(request, nombreEspecialidad: nombreEspecialidad);
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
  if (SesionActual.conectada && f.id != null) {
    await ProfesionalesApi().actualizar(
      f.id!,
      EditarProfesionalRequest(
        nombres: nombres,
        apellidos: apellidos,
        porcentaje: comisionPct,
        especialidadId: especialidad.id,
      ),
    );
  }
  return _cambiar(f, nombres: nombres, apellidos: apellidos, comisionPct: comisionPct, especialidad: especialidad);
}

Future<Fotografo> cambiarEstadoFotografo(Fotografo f, {required bool activo}) async {
  if (SesionActual.conectada && f.id != null) {
    await ProfesionalesApi().actualizar(f.id!, EditarProfesionalRequest(activo: activo));
  }
  if (activo) liberarAusencias(f.nombre, Reloj.hoy);
  return _cambiar(f, estado: activo ? EstadoFotografo.disponible : EstadoFotografo.inactivo);
}
