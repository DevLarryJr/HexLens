import '../../config/api_paths.dart';
import '../../models/especialidad.dart';
import '../../models/fotografo.dart';
import '../../models/profesional/profesional_request.dart';
import 'authenticated_api.dart';

class ProfesionalesApi extends AuthenticatedApi {
  ProfesionalesApi({super.api, super.token});

  Future<List<Fotografo>> listar({required NombreEspecialidad nombreEspecialidad}) async {
    final json = await api.get(ApiPaths.profesionales, headers: authHeaders);
    return parseJsonList(json, (p) => Fotografo.fromJson(p, nombreEspecialidad: nombreEspecialidad));
  }

  Future<List<Fotografo>> listarPorServicio(int servicioId, {required NombreEspecialidad nombreEspecialidad}) async {
    final json = await api.get(ApiPaths.profesionalesPorServicio(servicioId), headers: authHeaders);
    return parseJsonList(json, (p) => Fotografo.fromJson(p, nombreEspecialidad: nombreEspecialidad));
  }

  Future<Fotografo> crear(CrearProfesionalRequest request, {required NombreEspecialidad nombreEspecialidad}) async {
    final json = await api.post(ApiPaths.profesionales, body: request.toJson(), headers: authHeaders);
    return Fotografo.fromJson({...request.toJson(), ...objetoDeRespuesta(json)}, nombreEspecialidad: nombreEspecialidad);
  }

  Future<void> actualizar(int id, EditarProfesionalRequest request) async {
    await api.put(ApiPaths.profesional(id), body: request.toJson(), headers: authHeaders);
  }

  Future<void> eliminar(int id) async {
    await api.delete(ApiPaths.profesional(id), headers: authHeaders);
  }
}
