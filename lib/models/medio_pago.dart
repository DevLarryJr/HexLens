class MedioPago {
  const MedioPago(this.titulo, this.detalle, this.icon, this.iconWidth, this.iconHeight, {this.sugerido = false});

  final String titulo;
  final String detalle;

  final String icon;
  final double iconWidth;
  final double iconHeight;
  final bool sugerido;
}
