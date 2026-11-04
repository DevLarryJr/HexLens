import '../models/jornada.dart';

/// Inicio de la pausa de almuerzo (13:00), en minutos desde la medianoche.
const almuerzoInicioMin = 13 * 60;

/// Semana tipo de Laura Méndez a partir del [lunes]: L–V 08:00–17:00 con
/// almuerzo, sábado media jornada especial 09:00–14:00 y domingo libre.
List<Jornada> semanaLaura(DateTime lunes) => [
      for (var i = 0; i < 5; i++)
        Jornada(fecha: lunes.add(Duration(days: i)), inicioMin: 8 * 60, finMin: 17 * 60),
      Jornada(fecha: lunes.add(const Duration(days: 5)), inicioMin: 9 * 60, finMin: 14 * 60, almuerzo: false, especial: true),
      Jornada(fecha: lunes.add(const Duration(days: 6))),
    ];
