import '../../config/api_paths.dart';
import '../../models/common/json_utils.dart';
import '../../models/horario_laboral.dart';
import 'authenticated_api.dart';

class HorariosLaboralesApi extends AuthenticatedApi {
  HorariosLaboralesApi({super.api, super.token});

  Future<List<HorarioLaboral>> listarPorProfesional(int profesionalId) async {
    final json = await api.get(ApiPaths.horariosDeProfesional(profesionalId), headers: authHeaders);
    return [
      for (final h in parseJsonList(json, (h) => HorarioLaboral.tryFromJson(h, profesionalId: profesionalId)))
        ?h,
    ];
  }

  Future<HorarioLaboral> crear(HorarioLaboral horario) async {
    final json = await api.post(ApiPaths.horariosLaborales, body: horario.toCrearJson(), headers: authHeaders);
    return horario.conId(parseApiInt(primerCampo(objetoDeRespuesta(json), ['id', 'horarioLaboralId'])));
  }

  Future<void> actualizar(HorarioLaboral horario) async {
    await api.put(ApiPaths.horarioLaboral(horario.id!), body: horario.toActualizarJson(), headers: authHeaders);
  }
}
