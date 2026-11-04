import '../models/servicio.dart';
import 'api.dart';
import 'especialidades_api.dart';

/// Servicio de la app a partir de uno de la API (`/api/servicios`). [nombreEspecialidad] traduce el id de la
/// especialidad a su nombre (la API puede mandar el id, el nombre o un objeto con ambos).
Servicio servicioDesdeApi(Map json, {required String Function(int? id) nombreEspecialidad}) {
  final id = entero(campo(json, 'id') ?? campo(json, 'servicioId'));
  final esp = especialidadDeJson(json, nombreEspecialidad);
  return Servicio(
    id: id,
    codigo: Servicio.codigoDe(id),
    nombre: '${campo(json, 'nombre') ?? ''}'.trim(),
    categoria: esp.nombre,
    especialidadId: esp.id,
    duracionMin: entero(campo(json, 'duracion')) ?? 60,
    descripcion: '${campo(json, 'descripcion') ?? ''}'.trim(),
    precio: entero(campo(json, 'precio')) ?? 0,
  );
}

/// Cuerpo de `POST/PUT /api/servicios`.
Map<String, dynamic> servicioParaApi({
  required String nombre,
  required int precio,
  required String descripcion,
  required int duracionMin,
  required int especialidadId,
}) =>
    {
      'Nombre': nombre.trim(),
      'Precio': precio,
      'Descripcion': descripcion.trim(),
      'Duracion': duracionMin,
      'Especialidad': especialidadId,
    };

/// `GET /api/servicios`.
Future<List<Map>> obtenerServiciosApi() async {
  final datos = await Api.get('/api/servicios');
  return [for (final s in datos is List ? datos : const []) if (s is Map) s];
}

/// `POST /api/servicios`: devuelve el JSON del servicio creado (o el enviado si la API no lo devuelve).
Future<Map> crearServicioApi(Map<String, dynamic> cuerpo) async {
  final datos = await Api.post('/api/servicios', cuerpo);
  return datos is Map ? {...cuerpo, ...datos} : cuerpo;
}

/// `PUT /api/servicios/{id}`.
Future<void> actualizarServicioApi(int id, Map<String, dynamic> cuerpo) => Api.put('/api/servicios/$id', cuerpo);

/// `DELETE /api/servicios/{id}`.
Future<void> eliminarServicioApi(int id) => Api.delete('/api/servicios/$id');
