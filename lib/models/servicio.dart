import 'common/json_utils.dart';
import 'especialidad.dart';

class Servicio {
  const Servicio({
    required this.codigo,
    required this.nombre,
    required this.categoria,
    required this.duracionMin,
    required this.descripcion,
    required this.precio,
    this.id,
    this.especialidadId,
    this.ficha,
    this.popular = false,
    this.activo = true,
  });

  factory Servicio.fromJson(Map<String, dynamic> json, {required NombreEspecialidad nombreEspecialidad}) {
    final id = parseApiInt(campo(json, 'id') ?? campo(json, 'servicioId'));
    final esp = especialidadDeJson(json, nombreEspecialidad);
    return Servicio(
      id: id,
      codigo: codigoDe(id),
      nombre: parseApiText(json, 'nombre'),
      categoria: esp.nombre,
      especialidadId: esp.id,
      duracionMin: parseApiInt(campo(json, 'duracion')) ?? 60,
      descripcion: parseApiText(json, 'descripcion'),
      precio: parseApiInt(campo(json, 'precio')) ?? 0,
    );
  }

  final int? id;

  final String codigo;
  final String nombre;

  final String categoria;

  final int? especialidadId;
  final int duracionMin;

  final String descripcion;

  final String? ficha;

  final int precio;
  final bool popular;
  final bool activo;

  String get duracion => '$duracionMin min';

  static String codigoDe(int? id) => id == null ? '#SRV-NUEVO' : '#SRV-${id.toString().padLeft(3, '0')}';
}
