import '../utils/formato.dart';

class Jornada {
  const Jornada({
    required this.fecha,
    this.inicioMin,
    this.finMin,
    this.almuerzo = true,
    this.especial = false,
    this.almuerzoInicioMin,
    this.almuerzoFinMin,
  });

  final DateTime fecha;

  final int? inicioMin;
  final int? finMin;

  final bool almuerzo;

  final bool especial;

  final int? almuerzoInicioMin;
  final int? almuerzoFinMin;

  static const pausaAlmuerzoMin = 60;

  bool get libre => inicioMin == null || finMin == null;

  int get minutosAlmuerzo {
    if (!almuerzo) return 0;
    final desde = almuerzoInicioMin, hasta = almuerzoFinMin;
    return desde != null && hasta != null && hasta > desde ? hasta - desde : pausaAlmuerzoMin;
  }

  int get minutosEfectivos => libre ? 0 : finMin! - inicioMin! - minutosAlmuerzo;

  String get horas => '${minutosEfectivos ~/ 60}h';

  String get horario => libre ? '' : '${hhmm(inicioMin!)} - ${hhmm(finMin!)}';

  static String hhmm(int min) =>
      '${dosCifras(min ~/ 60)}:${dosCifras(min % 60)}';
}
