import '../models/especialidad.dart';
import 'api.dart';

/// Especialidad de la app a partir de una de la API (`/api/especialidades`).
Especialidad especialidadDesdeApi(Map json) {
  final id = campo(json, 'id') ?? campo(json, 'especialidadId');
  return Especialidad(
    id: id is int ? id : int.tryParse('${id ?? ''}'),
    nombre: '${campo(json, 'nombre') ?? ''}'.trim(),
  );
}

/// `GET /api/especialidades`.
Future<List<Especialidad>> obtenerEspecialidadesApi() async {
  final datos = await Api.get('/api/especialidades');
  final lista = datos is List ? datos : const [];
  return [for (final e in lista) if (e is Map) especialidadDesdeApi(e)];
}

/// `POST /api/especialidades`. Devuelve la que respondió la API o, si no la devuelve, la que se envió.
Future<Especialidad> crearEspecialidadApi(String nombre) async {
  final cuerpo = {'Nombre': nombre};
  final datos = await Api.post('/api/especialidades', cuerpo);
  return especialidadDesdeApi(datos is Map ? {...cuerpo, ...datos} : cuerpo);
}

/// `PUT /api/especialidades/{id}`: cambia el nombre.
Future<void> renombrarEspecialidadApi(int id, String nombre) => Api.put('/api/especialidades/$id', {'Nombre': nombre});

/// `DELETE /api/especialidades/{id}`.
Future<void> eliminarEspecialidadApi(int id) => Api.delete('/api/especialidades/$id');

/// Especialidad a la que apunta un servicio o un profesional de la API, que puede mandarla como id
/// (`"especialidad": 15`), como nombre o como objeto (`{id, nombre}`). [nombrePorId] traduce un id a su nombre.
({int? id, String nombre}) especialidadDeJson(Map json, String Function(int? id) nombrePorId) {
  final esp = campo(json, 'especialidad') ?? campo(json, 'especialidadId');
  if (esp is Map) {
    final id = entero(campo(esp, 'id'));
    return (id: id, nombre: '${campo(esp, 'nombre') ?? nombrePorId(id)}');
  }
  if (esp is String && int.tryParse(esp) == null) return (id: entero(campo(json, 'especialidadId')), nombre: esp);
  final id = entero(esp);
  return (id: id, nombre: nombrePorId(id));
}
