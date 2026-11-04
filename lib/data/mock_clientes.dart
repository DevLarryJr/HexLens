import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api.dart';
import '../api/clientes_api.dart';
import '../core/reloj.dart';
import '../models/cliente.dart';
import '../utils/formato.dart';

/// Clientes de ejemplo con los que arranca el directorio.
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

/// Directorio de clientes del estudio: los registrados en este celular (primero, del más
/// reciente al más antiguo) y luego los de ejemplo. Temporal hasta que se conecte la API.
final List<Cliente> clientes = [..._semilla];

/// Cliente que muestran por defecto las pantallas de la reserva cuando no se les pasa uno.
final clienteEjemplo = _semilla.first;

/// Cambia cada vez que se registra un cliente, para que las pantallas abiertas se actualicen.
final revisionClientes = ValueNotifier(0);

/// Clave del almacenamiento local donde se guardan los clientes registrados.
const _claveRegistrados = 'clientes_registrados';

/// Carga los clientes registrados en este celular. Se llama una vez al abrir la app.
Future<void> cargarClientesRegistrados() async {
  final prefs = await SharedPreferences.getInstance();
  final guardados = prefs.getStringList(_claveRegistrados) ?? const [];
  clientes
    ..clear()
    ..addAll([for (final json in guardados) Cliente.fromJson(jsonDecode(json) as Map<String, dynamic>)])
    ..addAll(_semilla);
  revisionClientes.value++;
}

Future<void> _guardarRegistrados() async {
  final prefs = await SharedPreferences.getInstance();
  final registrados = clientes.where((c) => c.estado == EstadoCliente.nuevo);
  await prefs.setStringList(_claveRegistrados, [for (final c in registrados) jsonEncode(c.toJson())]);
}

/// Crea un cliente nuevo (sin sesiones) con los datos de un formulario de registro y lo agrega
/// al inicio del directorio, guardándolo en el celular. [tipoDocumento] es "C.C.", "N.I.T." o "C.E.".
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

/// Con sesión en la API, reemplaza el directorio por los clientes de la API (`GET /api/clientes`).
/// Lanza [ApiError] si falla; el directorio queda como estaba.
Future<void> sincronizarClientes() async {
  if (!Api.conectada) return;
  final deLaApi = await obtenerClientesApi();
  clientes
    ..clear()
    ..addAll(deLaApi);
  revisionClientes.value++;
}

/// Registra un cliente desde un formulario: en la API si hay sesión (`POST /api/clientes`) o, si no,
/// solo en el celular ([registrarCliente]). Lanza [ApiError] si la API lo rechaza.
Future<Cliente> guardarCliente({
  required String tipoDocumento,
  required String documento,
  required String nombres,
  required String apellidos,
  required String telefono,
  String email = '',
  DateTime? nacimiento,
}) async {
  if (!Api.conectada) {
    return registrarCliente(
      tipoDocumento: tipoDocumento,
      documento: documento,
      nombres: nombres,
      apellidos: apellidos,
      telefono: telefono,
      email: email,
    );
  }
  // La API puede tener clientes que este celular aún no ha descargado: se pregunta antes de crear.
  final existente = await buscarClientePorDocumentoApi(documento);
  if (existente != null) {
    throw ApiError('Ya existe un cliente con ese documento (${existente.nombre})', codigo: 'CLIENT_EXISTS');
  }
  final cliente = await crearClienteApi(clienteParaApi(
    documento: documento,
    nombres: nombres,
    apellidos: apellidos,
    celular: telefono,
    correo: email,
    nacimiento: nacimiento,
  ));
  clientes.insert(0, cliente);
  revisionClientes.value++;
  return cliente;
}

/// Cliente por nombre, o null si no está en el directorio.
Cliente? clientePorNombre(String nombre) {
  for (final c in clientes) {
    if (c.nombre == nombre) return c;
  }
  return null;
}

/// Cliente con ese número de documento (se comparan solo los dígitos), o null.
Cliente? clientePorDocumento(String documento) {
  final digitos = soloDigitos(documento);
  if (digitos.isEmpty) return null;
  for (final c in clientes) {
    if (soloDigitos(c.documento) == digitos) return c;
  }
  return null;
}
