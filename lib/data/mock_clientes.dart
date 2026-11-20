import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/reloj.dart';
import '../models/cliente.dart';
import '../models/cliente/crear_cliente_request.dart';
import '../services/local/sesion_actual.dart';
import '../services/remote/api_service.dart';
import '../services/remote/clientes_api.dart';
import '../utils/formato.dart';

const _semilla = [
  Cliente(
    nombre: 'Valentina Ruiz',
    documento: 'C.C. 1.025.340.890',
    telefono: '+57 312 987 6543',
    email: 'valentina.ruiz@example.com',
    ciudad: 'Bogotá D.C.',
    estado: EstadoCliente.frecuente,
    detalle: 'Última: Retrato Profesional (15 Oct 2026)',
    foto: 'foto_valentina.jpg',
    sesiones: 3,
  ),
  Cliente(
    nombre: 'Andrés Molina',
    documento: 'C.C. 1.018.992.114',
    telefono: '+57 301 456 7890',
    email: 'andres.molina@example.com',
    estado: EstadoCliente.programada,
    detalle: 'Sesión familiar · 15 Oct, 14:00 Studio B',
    programadas: 1,
  ),
  Cliente(
    nombre: 'Camila Pérez',
    documento: 'C.C. 1.032.441.520',
    telefono: '+57 310 222 3344',
    email: 'camila.perez@example.com',
    estado: EstadoCliente.activaHoy,
    detalle: 'Fotografía de producto básica (E-comm)',
    foto: 'foto_camila.jpg',
    set: 'Set 01',
  ),
  Cliente(
    nombre: 'Daniel Castro',
    documento: 'C.C. 1.015.678.901',
    telefono: '+57 315 889 0012',
    email: 'd.castro@example.com',
    estado: EstadoCliente.realizada,
    detalle: 'Graduación individual · Entrega completa',
  ),
];

final List<Cliente> clientes = [..._semilla];

final clienteEjemplo = _semilla.first;

final revisionClientes = ValueNotifier(0);

const _claveRegistrados = 'clientes_registrados';

Future<void> cargarClientesRegistrados() async {
  final prefs = await SharedPreferences.getInstance();
  final guardados = prefs.getStringList(_claveRegistrados) ?? const [];
  clientes
    ..clear()
    ..addAll([for (final json in guardados) Cliente.fromLocalJson(jsonDecode(json) as Map<String, dynamic>)])
    ..addAll(_semilla);
  revisionClientes.value++;
}

Future<void> _guardarRegistrados() async {
  final prefs = await SharedPreferences.getInstance();
  final registrados = clientes.where((c) => c.estado == EstadoCliente.nuevo);
  await prefs.setStringList(_claveRegistrados, [for (final c in registrados) jsonEncode(c.toLocalJson())]);
}

Cliente registrarCliente({
  required String tipoDocumento,
  required String documento,
  required String nombres,
  required String apellidos,
  required String telefono,
  String email = '',
}) {
  final cliente = Cliente(
    nombre: '${nombres.trim()} ${apellidos.trim()}'.trim(),
    documento: '$tipoDocumento ${milesConPunto(soloDigitos(documento))}',
    telefono: '+57 ${telefonoConEspacios(soloDigitos(telefono))}',
    email: email.trim(),
    estado: EstadoCliente.nuevo,
    detalle: 'Registrado el ${fechaNumerica(Reloj.hoy)}',
  );
  clientes.insert(0, cliente);
  revisionClientes.value++;
  _guardarRegistrados();
  return cliente;
}

Future<void> sincronizarClientes() async {
  if (!SesionActual.conectada) return;
  final deLaApi = await ClientesApi().listar();
  clientes
    ..clear()
    ..addAll(deLaApi);
  revisionClientes.value++;
}

Future<Cliente> guardarCliente({
  required String tipoDocumento,
  required String documento,
  required String nombres,
  required String apellidos,
  required String telefono,
  String email = '',
  DateTime? nacimiento,
}) async {
  if (!SesionActual.conectada) {
    return registrarCliente(
      tipoDocumento: tipoDocumento,
      documento: documento,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      email: email,
    );
  }
  final clientesApi = ClientesApi();
  final existente = await clientesApi.consultar(documento);
  if (existente != null) {
    throw ApiException(
      'Ya existe un cliente con ese documento (${existente.nombre})',
      statusCode: 409,
      data: const {'code': 'CLIENT_EXISTS'},
    );
  }
  final request = CrearClienteRequest(
    documento: documento,
    nombres: nombres,
    apellidos: apellidos,
    celular: telefono,
    correo: email,
    fechaNacimiento: nacimiento,
  );
  final cliente = await clientesApi.crear(request);
  clientes.insert(0, cliente);
  revisionClientes.value++;
  return cliente;
}

Cliente? clientePorNombre(String nombre) {
  for (final c in clientes) {
    if (c.nombre == nombre) return c;
  }
  return null;
}

Cliente? clientePorDocumento(String documento) {
  final digitos = soloDigitos(documento);
  if (digitos.isEmpty) return null;
  for (final c in clientes) {
    if (soloDigitos(c.documento) == digitos) return c;
  }
  return null;
}
