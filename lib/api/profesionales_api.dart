import '../models/fotografo.dart';
import '../utils/formato.dart';
import 'api.dart';
import 'especialidades_api.dart';

String _texto(Map json, String nombre) => '${campo(json, nombre) ?? ''}'.trim();

/// Fotógrafo de la app a partir de un profesional de la API (`/api/profesionales`). [nombreEspecialidad]
/// traduce el id de la especialidad a su nombre (la API puede mandar el id, el nombre o un objeto).
Fotografo fotografoDesdeApi(Map json, {required String Function(int? id) nombreEspecialidad}) {
  final esp = especialidadDeJson(json, nombreEspecialidad);
  final nombres = _texto(json, 'nombres');
  final apellidos = _texto(json, 'apellidos');
  final documento = soloDigitos(_texto(json, 'documento'));
  final activo = campo(json, 'estado');
  return Fotografo(
    id: entero(campo(json, 'id') ?? campo(json, 'profesionalId')),
    nombre: [nombres, apellidos].where((p) => p.isNotEmpty).join(' '),
    nombres: nombres,
    apellidos: apellidos,
    documento: documento.isEmpty ? '' : 'C.C. ${milesConPunto(documento)}',
    especialidad: esp.nombre,
    especialidadId: esp.id,
    comisionPct: entero(campo(json, 'porcentaje')) ?? 0,
    // La API guarda Estado como true/false: falso = inactivo; activo = según su horario.
    estado: activo == false || activo == 0 ? EstadoFotografo.inactivo : EstadoFotografo.disponible,
  );
}

/// Cuerpo de `POST /api/profesionales`.
Map<String, dynamic> profesionalParaApi({
  required String documento,
  required String nombres,
  required String apellidos,
  required DateTime nacimiento,
  required int porcentaje,
  required bool activo,
  required int especialidadId,
}) =>
    {
      'Documento': soloDigitos(documento),
      'Nombres': nombres.trim(),
      'Apellidos': apellidos.trim(),
      'FechaNacimiento': '${nacimiento.year}-${dosCifras(nacimiento.month)}-${dosCifras(nacimiento.day)}',
      'Porcentaje': porcentaje,
      'Estado': activo,
      'Especialidad': especialidadId,
    };

Future<List<Map>> _lista(String ruta) async {
  final datos = await Api.get(ruta);
  return [for (final p in datos is List ? datos : const []) if (p is Map) p];
}

/// `GET /api/profesionales`.
Future<List<Map>> obtenerProfesionalesApi() => _lista('/api/profesionales');

/// `GET /api/profesionales/{especialidadId}/especialiades`: los profesionales de esa especialidad
/// (la ruta va escrita tal como está en la colección de Bruno).
Future<List<Map>> profesionalesPorEspecialidadApi(int especialidadId) =>
    _lista('/api/profesionales/$especialidadId/especialiades');

/// `POST /api/profesionales`: devuelve el JSON creado (o el enviado si la API no lo devuelve).
Future<Map> crearProfesionalApi(Map<String, dynamic> cuerpo) async {
  final datos = await Api.post('/api/profesionales', cuerpo);
  return datos is Map ? {...cuerpo, ...datos} : cuerpo;
}

/// `PUT /api/profesionales/{id}`: solo los campos que cambian (p. ej. `{Porcentaje: 45}` o `{Estado: true}`).
Future<void> actualizarProfesionalApi(int id, Map<String, dynamic> cambios) => Api.put('/api/profesionales/$id', cambios);

/// `DELETE /api/profesionales/{id}`.
Future<void> eliminarProfesionalApi(int id) => Api.delete('/api/profesionales/$id');
