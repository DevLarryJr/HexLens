import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proyecto_movil/data/mock_clientes.dart';
import 'package:proyecto_movil/models/cliente.dart';
import 'package:proyecto_movil/utils/formateadores.dart';

String escribir(TextInputFormatter formato, String texto) =>
    formato.formatEditUpdate(TextEditingValue.empty, TextEditingValue(text: texto)).text;

void main() {
  test('La cédula y el celular se separan mientras se escriben', () {
    expect(escribir(formatoDocumento, '1098765432'), '1.098.765.432');
    expect(escribir(formatoDocumento, '1.1034'), '11.034');
    expect(escribir(formatoDocumento, '52a.890 123'), '52.890.123');
    expect(escribir(formatoDocumento, '109876543299'), '1.098.765.432', reason: 'máximo 10 dígitos');
    expect(escribir(formatoTelefono, '3001234567'), '300 123 4567');
    expect(escribir(formatoTelefono, '3182'), '318 2');
    expect(escribir(formatoTelefono, '30012345679999'), '300 123 4567', reason: 'máximo 10 dígitos');
  });

  test('Un cliente registrado sigue ahí al volver a abrir la app', () async {
    await cargarClientesRegistrados();
    final antes = clientes.length;

    final nuevo = registrarCliente(
      tipoDocumento: 'C.C.',
      documento: '1098765432',
      nombres: 'Valentina',
      apellidos: 'Rojas Restrepo',
      telefono: '3001234567',
    );
    expect(nuevo.documento, 'C.C. 1.098.765.432');
    expect(nuevo.telefono, '+57 300 123 4567');
    await Future<void>.delayed(Duration.zero);

    clientes.clear();
    await cargarClientesRegistrados();
    expect(clientes.length, antes + 1);
    expect(clientes.first.nombre, 'Valentina Rojas Restrepo');
    expect(clientes.first.estado, EstadoCliente.nuevo);
    expect(clientePorDocumento('1098765432')?.telefono, '+57 300 123 4567');
    expect(clientes.where((c) => c.nombre == 'Valentina Ruiz').length, 1, reason: 'los de ejemplo no se duplican');
  });
}
