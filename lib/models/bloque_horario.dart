enum BloqueTipo { libre, ocupado, almuerzo, pasado }

class BloqueHorario {
  const BloqueHorario(this.inicio, this.tipo, this.nota, {this.duracionMin});

  final DateTime inicio;
  final BloqueTipo tipo;
  final String nota;

  final int? duracionMin;

  bool get libre => tipo == BloqueTipo.libre;

  DateTime fin(int duracionServicio) => inicio.add(Duration(minutes: duracionMin ?? duracionServicio));
}
