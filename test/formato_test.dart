import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_movil/utils/formato.dart';

void main() {
  test('formatCop agrupa miles con punto', () {
    expect(formatCop(0), r'$0');
    expect(formatCop(950), r'$950');
    expect(formatCop(120000), r'$120.000');
    expect(formatCop(1250000), r'$1.250.000');
    expect(formatCop(-4500), r'-$4.500');
  });

  test('Fechas en español', () {
    final d = DateTime(2024, 10, 24);
    expect(nombreDia(d), 'Jueves');
    expect(nombreDia(DateTime(2024, 10, 27)), 'Domingo');
    expect(nombreMes(d), 'Octubre');
    expect(mesCorto(d), 'Oct');
    expect(fechaLarga(d), 'Jueves, 24 de Octubre 2024');
  });

  test('Búsqueda sin importar tildes ni mayúsculas', () {
    expect(coincideBusqueda('jose', ['José Pérez']), isTrue);
    expect(coincideBusqueda('FOTOGRAFÍA', ['fotografia editorial']), isTrue);
    expect(coincideBusqueda('  ', ['lo que sea']), isTrue);
    expect(coincideBusqueda('moda', ['Retratos', 'Laura']), isFalse);
  });
}
