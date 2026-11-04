/// Opción para reasignar el fotógrafo de una sesión.
class OpcionStaff {
  const OpcionStaff({required this.nombre, required this.detalle, required this.etiqueta, this.automatica = false});

  final String nombre;
  final String detalle;

  /// Texto corto a la derecha: "98%\nMatch", "Senior", "AUTO".
  final String etiqueta;

  /// "Cualquier disponible": la asigna el sistema por carga de estudio.
  final bool automatica;
}
