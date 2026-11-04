/// Servicio fotográfico que ofrece el estudio.
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

  /// Id en la API (null en los servicios de ejemplo).
  final int? id;

  /// "#SRV-001"
  final String codigo;
  final String nombre;

  /// Nombre de la especialidad a la que pertenece: Retratos, Familiar, Productos, Editorial.
  final String categoria;

  /// Id de la especialidad en la API (null en los de ejemplo).
  final int? especialidadId;
  final int duracionMin;

  /// Descripción comercial (la que ve el cliente al reservar).
  final String descripcion;

  /// Ficha técnica del catálogo. Por defecto, la [descripcion].
  final String? ficha;

  /// Precio en pesos colombianos, sin decimales.
  final int precio;
  final bool popular;
  final bool activo;

  String get duracion => '$duracionMin min';

  /// Código a partir del id de la API: 7 → "#SRV-007".
  static String codigoDe(int? id) => id == null ? '#SRV-NUEVO' : '#SRV-${id.toString().padLeft(3, '0')}';
}
