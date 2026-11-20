class FranjaHoraria {
  const FranjaHoraria(this.hora, {this.inicio, this.bloqueo});

  final String hora;

  final DateTime? inicio;
  final String? bloqueo;

  bool get disponible => bloqueo == null;
}
