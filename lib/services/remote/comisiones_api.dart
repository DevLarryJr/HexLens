import '../../config/api_paths.dart';
import '../../models/cierre.dart';
import '../../models/liquidacion.dart';
import '../../models/liquidacion/liquidacion_request.dart';
import 'authenticated_api.dart';

class ComisionesApi extends AuthenticatedApi {
  ComisionesApi({super.api, super.token});

  Future<List<Cierre>> listarLiquidaciones() async {
    final json = await api.get(ApiPaths.liquidaciones, headers: authHeaders);
    final datos = desenvuelveRespuestaApi(json);
    if (datos is Map) return [parseJsonObject(datos, Cierre.fromJson)];
    return parseJsonList(json, Cierre.fromJson);
  }

  Future<Cierre> crearLiquidacion(LiquidacionRequest request) async {
    final json = await api.post(ApiPaths.liquidaciones, body: request.toJson(), headers: authHeaders);
    return Cierre.fromJson({...request.toJson(), ...objetoDeRespuesta(json)});
  }

  Future<List<Map<String, dynamic>>> listarComisiones(int cierreId) async {
    final json = await api.get(
      ApiPaths.comisiones,
      queryParameters: {'cierreId': cierreId, 'liquidacionComisionId': cierreId},
      headers: authHeaders,
    );
    return parseJsonList(json, (c) => c);
  }

  Future<List<SesionLiquidada>> listarServiciosDeComision(int comisionId) async {
    final json = await api.get(ApiPaths.serviciosDeComision(comisionId), headers: authHeaders);
    return parseJsonList(json, SesionLiquidada.fromJson);
  }
}
