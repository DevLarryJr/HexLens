import '../utils/formato.dart';
import 'fotografo.dart';

/// Sesión realizada que entra en una liquidación.
class SesionLiquidada {
  const SesionLiquidada(this.cliente, this.codigo, this.servicio, this.fecha, this.tarifa);

  final String cliente;

  /// "#RSV-2026-042"
  final String codigo;

  /// "Retrato Profesional"
  final String servicio;
  final DateTime fecha;

  /// Tarifa cobrada, en COP.
  final int tarifa;

  /// "Retrato Profesional • 15 Oct"
  String get detalle => '$servicio • ${diaMes(fecha)}';
}

/// Comisiones de un fotógrafo en un cierre: base = suma de tarifas, comisión = base × su tasa.
class Liquidacion {
  const Liquidacion(this.fotografo, this.sesiones);

  final Fotografo fotografo;
  final List<SesionLiquidada> sesiones;

  int get tasa => fotografo.comisionPct;
  int get base => sesiones.fold(0, (a, s) => a + s.tarifa);
  int get comision => comisionDe(base);
  int comisionDe(int tarifa) => tarifa * tasa ~/ 100;

  /// Solo las sesiones entre [inicio] y [fin] (ambos incluidos).
  Liquidacion entre(DateTime inicio, DateTime fin) => Liquidacion(fotografo, [
        for (final s in sesiones)
          if (!s.fecha.isBefore(inicio) && !s.fecha.isAfter(fin)) s,
      ]);
}
