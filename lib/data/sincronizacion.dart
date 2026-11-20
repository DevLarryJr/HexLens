import '../services/remote/api_service.dart';
import 'mock_agenda.dart';
import 'mock_cierres.dart';
import 'mock_clientes.dart';
import 'mock_especialidades.dart';
import 'mock_fotografos.dart';
import 'mock_servicios.dart';

Future<List<String>> sincronizarTodo() async {
  final cargas = [
    ('los clientes', sincronizarClientes),
    ('las especialidades', sincronizarEspecialidades),
    ('los servicios', sincronizarServicios),
    ('los fotógrafos', sincronizarFotografos),
    ('la agenda', sincronizarAgenda),
    ('los cierres', sincronizarCierres),
  ];
  final errores = <String>[];
  for (final (nombre, cargar) in cargas) {
    try {
      await cargar();
    } on ApiException catch (e) {
      errores.add('No se pudieron cargar $nombre: ${e.message}');
    }
  }
  return errores;
}
