import '../utils/formato.dart';

/// Jornada de trabajo de un fotógrafo en un día.
class Jornada {
  const Jornada({
    required this.fecha,
    this.inicioMin,
    this.finMin,
    this.almuerzo = true,
    this.especial = false,
  });

  final DateTime fecha;

  /// Inicio y fin en minutos desde la medianoche (08:00 → 480). Nulos = día libre.
  final int? inicioMin;
  final int? finMin;

  /// Incluye la pausa técnica de almuerzo ([pausaAlmuerzoMin] minutos).
  final bool almuerzo;

  /// Media jornada especial (no cuenta en la carga regular).
  final bool especial;

  static const pausaAlmuerzoMin = 60;

  bool get libre => inicioMin == null || finMin == null;

  int get minutosEfectivos => libre ? 0 : finMin! - inicioMin! - (almuerzo ? pausaAlmuerzoMin : 0);

  /// "8h"
  String get horas => '${minutosEfectivos ~/ 60}h';

  /// "08:00 - 17:00"
  String get horario => libre ? '' : '${hhmm(inicioMin!)} - ${hhmm(finMin!)}';

  /// 780 → "13:00".
  static String hhmm(int min) =>
      '${dosCifras(min ~/ 60)}:${dosCifras(min % 60)}';
}
