import 'package:flutter/foundation.dart';

import '../api/api.dart';
import '../api/especialidades_api.dart';
import '../models/especialidad.dart';
import '../models/fotografo.dart';
import 'mock_fotografos.dart';

/// Especialidades de ejemplo (sin sesión en la API).
const _ejemplo = [
  Especialidad(nombre: 'Retratos', rol: 'Titular técnica'),
  Especialidad(nombre: 'Familiar', rol: 'Titular técnico'),
  Especialidad(nombre: 'Productos', rol: 'Titular técnica'),
  Especialidad(nombre: 'Editorial', rol: 'Fotógrafo asignado'),
  Especialidad(nombre: 'Eventos y Corporativo', rol: 'Fotógrafo asignado'),
];

/// Especialidades del estudio: las de la API si hay sesión, si no las de ejemplo.
final List<Especialidad> especialidades = [..._ejemplo];

/// Cambia cada vez que se crea, renombra o elimina una especialidad.
final revisionEspecialidades = ValueNotifier(0);

void _avisar() => revisionEspecialidades.value++;

/// Con sesión en la API, reemplaza la lista por la de `GET /api/especialidades`. Lanza [ApiError] si falla.
Future<void> sincronizarEspecialidades() async {
  if (!Api.conectada) return;
  final deLaApi = await obtenerEspecialidadesApi();
  especialidades
    ..clear()
    ..addAll(deLaApi);
  _avisar();
}

/// Crea la especialidad (en la API si hay sesión) y la agrega a la lista.
Future<Especialidad> crearEspecialidad(String nombre) async {
  final limpio = nombre.trim();
  final nueva = Api.conectada ? await crearEspecialidadApi(limpio) : Especialidad(nombre: limpio);
  especialidades.add(nueva);
  _avisar();
  return nueva;
}

/// Cambia el nombre (en la API si hay sesión).
Future<Especialidad> renombrarEspecialidad(Especialidad e, String nombre) async {
  final limpio = nombre.trim();
  if (Api.conectada && e.id != null) await renombrarEspecialidadApi(e.id!, limpio);
  final renombrada = Especialidad(id: e.id, nombre: limpio, rol: e.rol);
  final i = especialidades.indexOf(e);
  if (i >= 0) especialidades[i] = renombrada;
  _avisar();
  return renombrada;
}

/// Elimina la especialidad (en la API si hay sesión). Si la API la rechaza, lanza [ApiError] y no se quita.
Future<void> eliminarEspecialidad(Especialidad e) async {
  if (Api.conectada && e.id != null) await eliminarEspecialidadApi(e.id!);
  especialidades.remove(e);
  _avisar();
}

/// Fotógrafo titular de la especialidad, o null si no hay.
Fotografo? titularDe(String especialidad) {
  for (final f in fotografos) {
    if (f.especialidad == especialidad) return f;
  }
  return null;
}

/// Nombre de la especialidad con ese id de la API ("Sin especialidad" si no está en la lista).
String nombreEspecialidad(int? id) =>
    especialidades.where((e) => e.id != null && e.id == id).firstOrNull?.nombre ?? 'Sin especialidad';
