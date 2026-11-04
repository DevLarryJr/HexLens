/// `pasado`: libre en la jornada, pero su hora de hoy ya transcurrió.
enum BloqueTipo { libre, ocupado, almuerzo, pasado }

/// Bloque de la jornada de un fotógrafo en un día.
class BloqueHorario {
  const BloqueHorario(this.inicio, this.tipo, this.nota, {this.duracionMin});

  final DateTime inicio;
  final BloqueTipo tipo;
  final String nota;

  /// Duración fija de bloques ocupados y almuerzo. En los libres es nula:
  /// la define el servicio que se va a agendar.
  final int? duracionMin;

  bool get libre => tipo == BloqueTipo.libre;

  /// Fin del bloque; en los libres, según la duración del servicio.
  DateTime fin(int duracionServicio) => inicio.add(Duration(minutes: duracionMin ?? duracionServicio));
}
