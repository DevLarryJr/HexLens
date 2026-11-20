import '../../extensions/date_time_extensions.dart';

class LiquidacionRequest {
  final DateTime fechaInicio;
  final DateTime fechaFin;

  const LiquidacionRequest({required this.fechaInicio, required this.fechaFin});

  Map<String, dynamic> toJson() => {
    'fechaInicio': fechaInicio.toIsoDateString(),
    'fechaFin': fechaFin.toIsoDateString(),
  };
}
