class EspecialidadRequest {
  final String nombre;

  const EspecialidadRequest({required this.nombre});

  Map<String, dynamic> toJson() => {'Nombre': nombre.trim()};
}
