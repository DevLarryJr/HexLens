import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_movil/data/estado_staff.dart';
import 'package:proyecto_movil/data/mock_fotografos.dart';
import 'package:proyecto_movil/models/fotografo.dart';

void main() {
  final laura = fotografoPorNombre('Laura Méndez')!;
  final nicolas = fotografoPorNombre('Nicolás Vega')!;
  DateTime jueves(int hora, [int min = 0]) => DateTime(2026, 10, 15, hora, min);

  test('Estado del staff según la hora real', () {
    expect(estadoPorHorario(laura, jueves(10, 15)), EstadoFotografo.enTurno); // sesión de Valentina 10:00–10:45
    expect(estadoPorHorario(laura, jueves(10, 50)), EstadoFotografo.disponible);
    expect(estadoPorHorario(laura, jueves(13, 20)), EstadoFotografo.almuerzo);
    expect(estadoPorHorario(laura, jueves(20)), EstadoFotografo.fueraDeTurno);
    expect(estadoPorHorario(laura, jueves(7, 30)), EstadoFotografo.fueraDeTurno);
    expect(estadoPorHorario(laura, DateTime(2026, 10, 18, 11)), EstadoFotografo.fueraDeTurno); // domingo
  });

  test('Inactivo por base o por inasistencia vigente', () {
    expect(estadoEnTiempoReal(nicolas, ahora: jueves(11)), EstadoFotografo.inactivo);
    expect(estadoEnTiempoReal(laura, ahora: jueves(11)), EstadoFotografo.disponible);
  });
}
