import '../../config/api_paths.dart';
import '../../models/especialidad.dart';
import '../../models/servicio.dart';
import '../../models/servicio/servicio_request.dart';
import 'authenticated_api.dart';

class ServiciosApi extends AuthenticatedApi {
  ServiciosApi({super.api, super.token});

  Future<List<Servicio>> listar({required NombreEspecialidad nombreEspecialidad}) async {
    final json = await api.get(ApiPaths.servicios, headers: authHeaders);
    return parseJsonList(json, (s) => Servicio.fromJson(s, nombreEspecialidad: nombreEspecialidad));
  }

  Future<Servicio> crear(ServicioRequest request, {required NombreEspecialidad nombreEspecialidad}) async {
    final json = await api.post(ApiPaths.servicios, body: request.toJson(), headers: authHeaders);
    return Servicio.fromJson({...request.toJson(), ...objetoDeRespuesta(json)}, nombreEspecialidad: nombreEspecialidad);
  }

  Future<void> actualizar(int id, ServicioRequest request) async {
    await api.put(ApiPaths.servicio(id), body: request.toJson(), headers: authHeaders);
  }

  Future<void> eliminar(int id) async {
    await api.delete(ApiPaths.servicio(id), headers: authHeaders);
  }
}
