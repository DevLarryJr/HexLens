import '../../config/api_paths.dart';
import '../../models/cliente.dart';
import '../../models/cliente/crear_cliente_request.dart';
import '../../utils/formato.dart';
import 'api_service.dart';
import 'authenticated_api.dart';

class ClientesApi extends AuthenticatedApi {
  ClientesApi({super.api, super.token});

  Future<List<Cliente>> listar() async {
    final json = await api.get(ApiPaths.clientes, headers: authHeaders);
    return parseJsonList(json, Cliente.fromJson);
  }

  Future<Cliente?> consultar(String documento) async {
    final Object? json;
    try {
      json = await api.get(ApiPaths.cliente(soloDigitos(documento)), headers: authHeaders);
    } on ApiException catch (e) {
      if (e.isNotFound) return null;
      rethrow;
    }
    final datos = desenvuelveRespuestaApi(json);
    final unico = datos is List ? datos.firstOrNull : datos;
    return unico is Map ? parseJsonObject(unico, Cliente.fromJson) : null;
  }

  Future<Cliente> crear(CrearClienteRequest request) async {
    final json = await api.post(ApiPaths.clientes, body: request.toJson(), headers: authHeaders);
    return Cliente.fromJson({...request.toJson(), ...objetoDeRespuesta(json)});
  }
}
