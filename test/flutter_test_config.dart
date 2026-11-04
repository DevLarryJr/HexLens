import 'dart:async';

import 'package:proyecto_movil/core/reloj.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Todas las pruebas corren con el reloj fijo en el jueves 15 de octubre de 2026, 09:45,
/// para que los datos de ejemplo (anclados a "hoy") den siempre los mismos resultados.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  Reloj.fijar(DateTime(2026, 10, 15, 9, 45));
  // Almacenamiento local en memoria y vacío: cada archivo de pruebas arranca sin clientes registrados.
  SharedPreferences.setMockInitialValues({});
  await testMain();
}
