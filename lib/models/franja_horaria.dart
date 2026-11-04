/// Franja horaria de la agenda. Si [bloqueo] no es nulo, no se puede elegir
/// y se muestra ese motivo (p. ej. "OCUPADO", "CIERRE").
class FranjaHoraria {
  const FranjaHoraria(this.hora, {this.inicio, this.bloqueo});

  /// Hora de inicio en formato "09:00 AM".
  final String hora;

  /// Fecha y hora exactas de inicio, cuando la franja pertenece a un día concreto.
  final DateTime? inicio;
  final String? bloqueo;

  bool get disponible => bloqueo == null;
}
