class OpcionStaff {
  const OpcionStaff({required this.nombre, required this.detalle, required this.etiqueta, this.automatica = false});

  final String nombre;
  final String detalle;

  final String etiqueta;

  final bool automatica;
}
