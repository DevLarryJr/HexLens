import '../../config/api_paths.dart';
import '../../models/especialidad.dart';
import '../../models/especialidad/especialidad_request.dart';
import 'authenticated_api.dart';

class EspecialidadesApi extends AuthenticatedApi {
  EspecialidadesApi({super.api, super.token});

  Future<List<Especialidad>> listar() async {
    final json = await api.get(ApiPaths.especialidades, headers: authHeaders);
    return parseJsonList(json, Especialidad.fromJson);
  }

  Future<Especialidad> crear(EspecialidadRequest request) async {
    final json = await api.post(ApiPaths.especialidades, body: request.toJson(), headers: authHeaders);
    return Especialidad.fromJson({...request.toJson(), ...objetoDeRespuesta(json)});
  }

  Future<void> actualizar(int id, EspecialidadRequest request) async {
    await api.put(ApiPaths.especialidad(id), body: request.toJson(), headers: authHeaders);
  }

  Future<void> eliminar(int id) async {
    await api.delete(ApiPaths.especialidad(id), headers: authHeaders);
  }
}
