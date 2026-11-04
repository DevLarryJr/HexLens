import '../models/cliente.dart';
import '../utils/formato.dart';
import 'api.dart';

String _texto(Map json, String nombre) => '${campo(json, nombre) ?? ''}'.trim();

/// Cliente de la app a partir de uno de la API (`/api/clientes`).
Cliente clienteDesdeApi(Map json) {
  final id = campo(json, 'id') ?? campo(json, 'clienteId');
  final documento = soloDigitos(_texto(json, 'documento'));
  final celular = soloDigitos(_texto(json, 'celular'));
  final nombre = [_texto(json, 'nombres'), _texto(json, 'apellidos')].where((p) => p.isNotEmpty).join(' ');
  return Cliente(
    id: id is int ? id : int.tryParse('${id ?? ''}'),
    nombre: nombre.isEmpty ? _texto(json, 'nombre') : nombre,
    documento: documento.isEmpty ? '' : 'C.C. ${milesConPunto(documento)}',
    telefono: celular.isEmpty ? '' : '+57 ${telefonoConEspacios(celular)}',
    email: _texto(json, 'correo'),
    estado: EstadoCliente.nuevo,
    detalle: 'Cliente registrado en el sistema',
  );
}

/// Cuerpo de `POST /api/clientes`: solo dígitos en documento y celular, fecha como "1990-05-15".
Map<String, dynamic> clienteParaApi({
  required String documento,
  required String nombres,
  required String apellidos,
  required String celular,
  String correo = '',
  DateTime? nacimiento,
}) =>
    {
      'Documento': soloDigitos(documento),
      'Nombres': nombres.trim(),
      'Apellidos': apellidos.trim(),
      'Celular': soloDigitos(celular),
      if (correo.trim().isNotEmpty) 'Correo': correo.trim(),
      if (nacimiento != null)
        'FechaNacimiento': '${nacimiento.year}-${dosCifras(nacimiento.month)}-${dosCifras(nacimiento.day)}',
    };

/// `GET /api/clientes`.
Future<List<Cliente>> obtenerClientesApi() async {
  final datos = await Api.get('/api/clientes');
  final lista = datos is List ? datos : const [];
  return [for (final c in lista) if (c is Map) clienteDesdeApi(c)];
}

/// `GET /api/clientes/{documento}`: el cliente con ese documento, o null si no existe (404).
Future<Cliente?> buscarClientePorDocumentoApi(String documento) async {
  try {
    final datos = await Api.get('/api/clientes/${soloDigitos(documento)}');
    final json = datos is List ? datos.firstOrNull : datos;
    return json is Map ? clienteDesdeApi(json) : null;
  } on ApiError catch (e) {
    if (e.estado == 404) return null;
    rethrow;
  }
}

/// `POST /api/clientes`. Devuelve el cliente que respondió la API o, si no lo devuelve, el que se envió.
Future<Cliente> crearClienteApi(Map<String, dynamic> cuerpo) async {
  final datos = await Api.post('/api/clientes', cuerpo);
  return clienteDesdeApi(datos is Map ? {...cuerpo, ...datos} : cuerpo);
}
