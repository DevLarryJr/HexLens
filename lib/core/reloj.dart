/// Fuente única de la fecha y hora de la app.
///
/// En la app es la hora real del teléfono; en las pruebas se fija con [Reloj.fijar]
/// para que los resultados no dependan del día en que se ejecutan.
abstract final class Reloj {
  static DateTime Function() _fuente = DateTime.now;

  /// Fecha y hora actuales.
  static DateTime ahora() => _fuente();

  /// Hoy a medianoche.
  static DateTime get hoy {
    final a = ahora();
    return DateTime(a.year, a.month, a.day);
  }

  /// Día a [dias] de hoy (negativo = pasado), a la [hora]:[minuto] indicada.
  static DateTime dia(int dias, [int hora = 0, int minuto = 0]) {
    final h = hoy;
    return DateTime(h.year, h.month, h.day + dias, hora, minuto);
  }

  /// Congela el reloj en [momento] (para pruebas).
  static void fijar(DateTime momento) => _fuente = () => momento;

  /// Vuelve a la hora real.
  static void real() => _fuente = DateTime.now;
}
