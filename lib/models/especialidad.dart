import '../utils/formato.dart';

/// Especialidad fotográfica del estudio (agrupa servicios y tiene un titular).
class Especialidad {
  const Especialidad({
    required this.nombre,
    this.id,
    this.rol = 'Titular',
  });

  /// Id en la API (null en las especialidades de ejemplo).
  final int? id;

  final String nombre;

  /// "Titular técnica", "Fotógrafo asignado"…
  final String rol;

  /// Ícono según el nombre (SVG dentro de `assets/icons/` y su tamaño en Figma); uno genérico si no se reconoce.
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
