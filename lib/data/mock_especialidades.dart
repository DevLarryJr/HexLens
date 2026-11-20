import 'package:flutter/foundation.dart';

import '../models/especialidad.dart';
import '../models/especialidad/especialidad_request.dart';
import '../models/fotografo.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/especialidades_api.dart';
import 'mock_fotografos.dart';

const _ejemplo = [
  Especialidad(nombre: 'Retratos', rol: 'Titular técnica'),
  Especialidad(nombre: 'Familiar', rol: 'Titular técnico'),
  Especialidad(nombre: 'Productos', rol: 'Titular técnica'),
  Especialidad(nombre: 'Editorial', rol: 'Fotógrafo asignado'),
  Especialidad(nombre: 'Eventos y Corporativo', rol: 'Fotógrafo asignado'),
];

final List<Especialidad> especialidades = [..._ejemplo];

final revisionEspecialidades = ValueNotifier(0);

void _avisar() => revisionEspecialidades.value++;

Future<void> sincronizarEspecialidades() async {
  if (!SesionActual.conectada) return;
  final deLaApi = await EspecialidadesApi().listar();
  especialidades
    ..clear()
    ..addAll(deLaApi);
  _avisar();
}

Future<Especialidad> crearEspecialidad(String nombre) async {
  final limpio = nombre.trim();
  var nueva = Especialidad(nombre: limpio);
  if (SesionActual.conectada) {
    nueva = await EspecialidadesApi().crear(EspecialidadRequest(nombre: limpio));
  }
  especialidades.add(nueva);
  _avisar();
  return nueva;
}

Future<Especialidad> renombrarEspecialidad(Especialidad e, String nombre) async {
  final limpio = nombre.trim();
  if (SesionActual.conectada && e.id != null) {
    await EspecialidadesApi().actualizar(e.id!, EspecialidadRequest(nombre: limpio));
  }
  final renombrada = Especialidad(id: e.id, nombre: limpio, rol: e.rol);
  final i = especialidades.indexOf(e);
  if (i >= 0) especialidades[i] = renombrada;
  _avisar();
  return renombrada;
}

Future<void> eliminarEspecialidad(Especialidad e) async {
  if (SesionActual.conectada && e.id != null) {
    await EspecialidadesApi().eliminar(e.id!);
  }
  especialidades.remove(e);
  _avisar();
}

Fotografo? titularDe(String especialidad) {
  for (final f in fotografos) {
    if (f.especialidad == especialidad) return f;
  }
  return null;
}

String nombreEspecialidad(int? id) =>
    especialidades.where((e) => e.id != null && e.id == id).firstOrNull?.nombre ?? 'Sin especialidad';
