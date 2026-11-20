import '../utils/formato.dart';
import 'common/json_utils.dart';

typedef NombreEspecialidad = String Function(int? id);

class Especialidad {
  const Especialidad({
    required this.nombre,
    this.id,
    this.rol = 'Titular',
  });

  factory Especialidad.fromJson(Map<String, dynamic> json) => Especialidad(
        id: parseApiInt(campo(json, 'id') ?? campo(json, 'especialidadId')),
        nombre: parseApiText(json, 'nombre'),
      );

  final int? id;

  final String nombre;

  final String rol;

  ({String svg, double ancho, double alto}) get icono {
    final n = sinTildes(nombre);
    if (n.contains('retrat')) return (svg: 'especialidades/retratos.svg', ancho: 18.333, alto: 18.333);
    if (n.contains('famil') || n.contains('matern')) return (svg: 'especialidades/familiar.svg', ancho: 22, alto: 17.417);
    if (n.contains('product')) return (svg: 'especialidades/productos.svg', ancho: 18.333, alto: 18.333);
    if (n.contains('editorial') || n.contains('moda')) {
      return (svg: 'especialidades/editorial.svg', ancho: 20.167, alto: 17.875);
    }
    if (n.contains('evento') || n.contains('corporativ')) return (svg: 'especialidades/eventos.svg', ancho: 16.5, alto: 16.5);
    return (svg: 'especialidades/servicios.svg', ancho: 16.667, alto: 17.5);
  }
}

({int? id, String nombre}) especialidadDeJson(Map json, NombreEspecialidad nombrePorId) {
  final esp = campo(json, 'especialidad') ?? campo(json, 'especialidadId');
  if (esp is Map) {
    final id = parseApiInt(campo(esp, 'id'));
    return (id: id, nombre: '${campo(esp, 'nombre') ?? nombrePorId(id)}');
  }
  if (esp is String && int.tryParse(esp) == null) return (id: parseApiInt(campo(json, 'especialidadId')), nombre: esp);
  final id = parseApiInt(esp);
  return (id: id, nombre: nombrePorId(id));
}
