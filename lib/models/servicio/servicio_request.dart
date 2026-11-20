class ServicioRequest {
  final String nombre;
  final int precio;
  final String descripcion;
  final int duracionMin;
  final int especialidadId;

  const ServicioRequest({
    required this.nombre,
    required this.precio,
    required this.descripcion,
    required this.duracionMin,
    required this.especialidadId,
  });

  Map<String, dynamic> toJson() => {
    'Nombre': nombre.trim(),
    'Precio': precio,
    'Descripcion': descripcion.trim(),
    'Duracion': duracionMin,
    'Especialidad': especialidadId,
  };
}
