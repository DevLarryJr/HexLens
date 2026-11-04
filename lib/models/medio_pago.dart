/// Medio de pago que se registra al confirmar una reserva (control operativo,
/// no pasarela bancaria).
class MedioPago {
  const MedioPago(this.titulo, this.detalle, this.icon, this.iconWidth, this.iconHeight, {this.sugerido = false});

  final String titulo;
  final String detalle;

  /// Ruta dentro de `assets/icons/`.
  final String icon;
  final double iconWidth;
  final double iconHeight;
  final bool sugerido;
}
