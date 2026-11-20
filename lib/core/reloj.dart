abstract final class Reloj {
  static DateTime Function() _fuente = DateTime.now;

  static DateTime ahora() => _fuente();

  static DateTime get hoy {
    final a = ahora();
    return DateTime(a.year, a.month, a.day);
  }

  static DateTime dia(int dias, [int hora = 0, int minuto = 0]) {
    final h = hoy;
    return DateTime(h.year, h.month, h.day + dias, hora, minuto);
  }

  static void fijar(DateTime momento) => _fuente = () => momento;

  static void real() => _fuente = DateTime.now;
}
